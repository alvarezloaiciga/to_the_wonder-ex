defmodule ToTheWonderWeb.Admin.Users.EditLive do
  use ToTheWonderWeb, :live_view
  alias ToTheWonder.Accounts

  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user!(id)

    {:ok,
     socket
     |> assign(:page_title, "Edit User")
     |> assign(:current_page, :users)
     |> assign(:user, user)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-12 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <.live_component
        module={ToTheWonderWeb.Users.FormComponent}
        id={@user.id}
        action={~p"/admin/users/#{@user}"}
        user={@user}
      />
    </div>
    """
  end
end
