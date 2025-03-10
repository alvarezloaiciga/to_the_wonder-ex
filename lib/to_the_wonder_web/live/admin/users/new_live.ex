defmodule ToTheWonderWeb.Admin.Users.NewLive do
  use ToTheWonderWeb, :live_view
  alias ToTheWonder.Accounts
  alias ToTheWonderWeb.Users.FormComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    user = %Accounts.User{}

    {:noreply,
     socket
     |> assign(:page_title, "New User")
     |> assign(:user, user)
     |> assign(:current_page, "users")
     |> assign(:action, :new)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8 divide-y divide-gray-900/10">
      <div class="space-y-8 divide-y divide-gray-900/10 sm:space-y-0">
        <div class="pb-6">
          <h2 class="text-base font-semibold leading-7 text-gray-900">New User</h2>
          <p class="mt-1 text-sm leading-6 text-gray-600">
            Create a new user account.
          </p>
        </div>

        <.live_component module={FormComponent} id={:new} action={@action} user={@user} />
      </div>
    </div>
    """
  end
end
