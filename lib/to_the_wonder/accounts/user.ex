defmodule ToTheWonder.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :picture, :map
    field :bio, :string
    field :instagram_handle, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :name, :picture, :bio, :instagram_handle])
    |> validate_email(opts)
    |> validate_password(opts)
    |> validate_name()
    |> validate_bio()
    |> validate_instagram_handle()
    |> handle_picture()
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, ToTheWonder.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%ToTheWonder.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 50)
  end

  defp validate_bio(changeset) do
    changeset
    |> validate_length(:bio, max: 500, message: "bio must be less than 500 characters")
  end

  defp validate_instagram_handle(changeset) do
    changeset
    |> validate_format(:instagram_handle, ~r/^@?[a-zA-Z0-9._]{1,30}$/,
      message: "must be a valid Instagram handle")
    |> update_change(:instagram_handle, fn
      nil -> nil
      handle ->
        handle = if String.starts_with?(handle, "@"), do: handle, else: "@#{handle}"
        String.downcase(handle)
    end)
  end

  defp handle_picture(changeset) do
    if upload = get_change(changeset, :picture) do
      if Mix.env() == :prod do
        case upload_pictures_to_aws(upload) do
          {:ok, urls} -> put_change(changeset, :picture, urls)
          {:error, error} -> add_error(changeset, :picture, "failed to upload: #{error}")
        end
      else
        # In development/test, just store the filename
        put_change(changeset, :picture, %{
          "original" => upload.filename,
          "large" => upload.filename,
          "medium" => upload.filename,
          "small" => upload.filename
        })
      end
    else
      changeset
    end
  end

  defp upload_pictures_to_aws(%{path: path, filename: filename}) do
    bucket = System.get_env("AWS_BUCKET_NAME")
    unique_id = UUID.uuid4()

    try do
      {:ok, original_binary} = File.read(path)

      sizes = %{
        "original" => nil,
        "large" => "800x800",
        "medium" => "400x400",
        "small" => "200x200"
      }

      urls =
        Enum.reduce(sizes, %{}, fn {size_name, dimensions}, acc ->
          unique_filename = "#{unique_id}-#{size_name}-#{filename}"

          image_binary =
            if dimensions do
              {:ok, resized} =
                Image.open(path)
                |> Image.resize(dimensions)
                |> Image.save(in_memory: true)
              resized
            else
              original_binary
            end

          case ExAws.S3.put_object(bucket, unique_filename, image_binary, [
            acl: :public_read,
            content_type: MIME.from_path(filename)
          ]) |> ExAws.request() do
            {:ok, _} ->
              Map.put(acc, size_name, "https://#{bucket}.s3.amazonaws.com/#{unique_filename}")
            {:error, error} ->
              raise "Failed to upload #{size_name}: #{inspect(error)}"
          end
        end)

      {:ok, urls}
    rescue
      e -> {:error, "Image processing failed: #{inspect(e)}"}
    end
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :bio, :instagram_handle, :picture])
    |> validate_required([:name, :email])
    |> validate_email([])
    |> validate_bio()
    |> validate_instagram_handle()
    |> handle_picture()
  end
end
