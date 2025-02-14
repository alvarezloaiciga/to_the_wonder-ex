defmodule ToTheWonderWeb.Users.FormComponent do
  use ToTheWonderWeb, :html
  use ToTheWonderWeb, :live_component
  alias ToTheWonder.Accounts
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user_profile(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> allow_upload(:picture,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 10_000_000)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :picture, fn %{path: path}, entry ->
        ext = Path.extname(entry.client_name)
        random_filename = :crypto.strong_rand_bytes(20) |> Base.url_encode64() |> binary_part(0, 20)
        filename = random_filename <> ext
        dest = Path.join([:code.priv_dir(:to_the_wonder), "static", "uploads", filename])
        File.cp!(path, dest)
        {:ok, "/uploads/" <> filename}
      end)

    user_params =
      case uploaded_files do
        [path] -> Map.put(user_params, "picture", %{filename: path})
        [] -> user_params
      end

    case Accounts.update_user_profile(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(to: ~p"/admin/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :picture, ref)}
  end


  def render(assigns) do
    ~H"""
    <div>
    <.simple_form :let={f} for={@changeset} phx-target={@myself} action={@action} phx-submit="save" phx-change="validate" multipart>
      <div class="space-y-12 max-w-3xl">
        <div class="border-b border-gray-900/10 pb-12">
          <h2 class="text-base/7 font-semibold text-gray-900">Profile</h2>
          <p class="mt-1 text-sm/6 text-gray-600">This information will be displayed publicly so be careful what you share.</p>

          <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6">
            <div class="sm:col-span-4">
              <.input
                field={f[:name]}
                type="text"
                label="Name"
                required
                class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6"
              />
            </div>

            <div class="sm:col-span-4">
              <.input
                field={f[:email]}
                type="email"
                label="Email"
                required
                class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6"
              />
            </div>

            <div class="sm:col-span-4">
              <.input
                field={f[:bio]}
                type="textarea"
                label="Bio"
                class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6"
              />
              <p class="mt-3 text-sm/6 text-gray-600">Write a few sentences about yourself.</p>
            </div>

            <div class="sm:col-span-4">
              <label class="block text-sm/6 font-medium text-gray-900">Profile Picture</label>
              <div class="mt-2 flex flex-col gap-x-3">
                <%= if Enum.any?(@uploads.picture.entries) do %>
                <div>
                  <section phx-drop-target={@uploads.picture.ref}>
                    <article :for={entry <- @uploads.picture.entries} class="upload-entry">
                      <figure>
                        <.live_img_preview entry={entry} />
                      </figure>

                      <button type="button" phx-target={@myself} phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel">&times;</button>

                      <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                      <p :for={err <- upload_errors(@uploads.picture, entry)} class="alert alert-danger">{error_to_string(err)}</p>
                    </article>

                    <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
                    <p :for={err <- upload_errors(@uploads.picture)} class="alert alert-danger">
                      {error_to_string(err)}
                    </p>
                  </section>
                </div>
                <% else %>
                  <svg class="size-12 text-gray-300" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M18.685 19.097A9.723 9.723 0 0 0 21.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 0 0 3.065 7.097A9.716 9.716 0 0 0 12 21.75a9.716 9.716 0 0 0 6.685-2.653Zm-12.54-1.285A7.486 7.486 0 0 1 12 15a7.486 7.486 0 0 1 5.855 2.812A8.224 8.224 0 0 1 12 20.25a8.224 8.224 0 0 1-5.855-2.438ZM15.75 9a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" clip-rule="evenodd" />
                  </svg>
                <% end %>
                <.live_file_input
                  upload={@uploads.picture}
                  class="rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                />
              </div>
              <.error :for={err <- upload_errors(@uploads.picture)}>
                <%= Phoenix.Naming.humanize(err) %>
              </.error>
            </div>

            <div class="sm:col-span-4">
              <.input
                field={f[:instagram_handle]}
                type="text"
                label="Instagram Handle"
                class="block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6"
              />
            </div>
          </div>
        </div>
      </div>

      <div class="mt-6 flex items-center justify-end gap-x-6 max-w-3xl">
        <.link navigate={~p"/admin/users"} class="text-sm/6 font-semibold text-gray-900">Cancel</.link>
        <.button type="submit" phx-disable-with="Saving..." class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
          Save User
        </.button>
      </div>
    </.simple_form>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
