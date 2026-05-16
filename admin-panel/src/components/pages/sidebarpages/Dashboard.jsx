export default function Dashboard() {
  return (
    <div className="space-y-6">
      <div className="bg-white shadow-lg rounded-xl p-6">
        <h1 className="text-2xl font-semibold mb-1">Dashboard</h1>
        <p className="text-gray-600">Welcome to the Admin Panel!</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white shadow-md p-5 rounded-xl">
          <h3 className="text-gray-500">Total Users</h3>
          <p className="text-3xl font-bold mt-2">1,205</p>
        </div>

        <div className="bg-white shadow-md p-5 rounded-xl">
          <h3 className="text-gray-500">Active Sessions</h3>
          <p className="text-3xl font-bold mt-2">89</p>
        </div>

        <div className="bg-white shadow-md p-5 rounded-xl">
          <h3 className="text-gray-500">Revenue</h3>
          <p className="text-3xl font-bold mt-2">$4,250</p>
        </div>
      </div>
    </div>
  );
}