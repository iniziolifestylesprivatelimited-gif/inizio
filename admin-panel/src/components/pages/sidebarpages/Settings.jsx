export default function Settings() {
  return (
    <div className="bg-white shadow-lg rounded-xl p-6">
      <h1 className="text-2xl font-semibold mb-4">Settings</h1>

      <div className="space-y-4">
        <div>
          <label className="block text-gray-600">Username</label>
          <input
            className="border rounded px-3 py-2 mt-1 w-full"
            placeholder="Enter your username"
          />
        </div>

        <div>
          <label className="block text-gray-600">Email</label>
          <input
            className="border rounded px-3 py-2 mt-1 w-full"
            placeholder="Enter your email"
          />
        </div>

        <button className="bg-black text-white px-4 py-2 rounded-lg mt-2">
          Save Changes
        </button>
      </div>
    </div>
  );
}
