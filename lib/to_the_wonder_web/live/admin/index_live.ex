defmodule ToTheWonderWeb.Admin.IndexLive do
  use ToTheWonderWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Admin Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Admin Dashboard</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Users Card -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold mb-4">Users</h2>
          <div class="text-4xl font-bold text-blue-600">123</div>
          <p class="text-gray-600">Total registered users</p>
        </div>
        
    <!-- Analytics Card -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold mb-4">Page Views</h2>
          <div class="text-4xl font-bold text-green-600">1,234</div>
          <p class="text-gray-600">Last 7 days</p>
        </div>
        
    <!-- Revenue Card -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold mb-4">Revenue</h2>
          <div class="text-4xl font-bold text-purple-600">$5,678</div>
          <p class="text-gray-600">This month</p>
        </div>
      </div>
      
    <!-- Chart Section -->
      <div class="mt-8 bg-white rounded-lg shadow-md p-6">
        <h2 class="text-xl font-semibold mb-4">Analytics Overview</h2>
        <div class="h-64">
          <!-- Add your chart component here -->
          <p class="text-gray-600">
            Chart placeholder - integrate with your preferred charting library
          </p>
        </div>
      </div>
    </div>
    """
  end
end
