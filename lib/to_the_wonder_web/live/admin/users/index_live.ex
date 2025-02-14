defmodule ToTheWonderWeb.Admin.Users.IndexLive do
  use ToTheWonderWeb, :live_view

  alias ToTheWonder.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    {:ok, assign(socket, users: users, current_page: :users)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-14">
        <h1 class="text-2xl font-bold">Users</h1>
        <.link navigate={~p"/admin/users/new"} class="btn btn-primary">
          New User
        </.link>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <%= for user <- @users do %>
          <div class="card bg-base-100 shadow-xl rounded-xl">
            <div class="card-body">
              <div class="flex items-center space-x-4 px-4">
                <%= if user.picture["small"] do %>
                  <div class="avatar">
                    <div class="w-16 h-16 rounded-full overflow-hidden">
                      <img src={user.picture["small"]} alt={user.name} class="w-full h-full object-cover rounded-full">
                    </div>
                  </div>
                <% else %>
                  <div class="rounded-full bg-base-200 p-4">
                    <.icon name="hero-user" class="w-8 h-8" />
                  </div>
                <% end %>
                <div>
                  <h2 class="card-title"><%= user.name %></h2>
                  <p class="text-gray-600"><%= user.email %></p>
                </div>
              </div>

              <div class="card-actions flex justify-end mt-6 space-x-2 p-4 border-t">
                <.link navigate={~p"/admin/users/#{user}/show"} class="btn btn-ghost btn-sm">
                  <.icon name="hero-eye" class="w-5 h-5 text-blue-500" />
                </.link>
                <.link navigate={~p"/admin/users/#{user}/edit"} class="btn btn-ghost btn-sm">
                  <.icon name="hero-pencil-square" class="w-5 h-5 text-yellow-500" />
                </.link>
                <.link
                  phx-click="delete"
                  phx-value-id={user.id}
                  data-confirm="Are you sure?"
                  class="btn btn-ghost btn-sm">
                  <.icon name="hero-trash" class="w-5 h-5 text-red-500" />
                </.link>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, users: Accounts.list_users())}
  end
end
