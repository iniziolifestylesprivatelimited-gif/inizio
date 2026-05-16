import { useEffect, useState } from "react";
import axios from "axios";
import { API_BASE_URL } from "../../../config/constants";
import { useAuth } from "../../../context/AuthContext";

export default function SendNotification() {
  const { admin } = useAuth();
  const [customers, setCustomers] = useState([]);
  const [customerId, setCustomerId] = useState("");
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");

  const [notifications, setNotifications] = useState([]);

  useEffect(() => {
    axios.get(`${API_BASE_URL}/api/admin/customers`, {
      headers: { Authorization: `Bearer ${admin.token}` }
    }).then(res => setCustomers(res.data));

    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    const res = await axios.get(`${API_BASE_URL}/api/admin/notifications`, {
      headers: { Authorization: `Bearer ${admin.token}` }
    });
    setNotifications(res.data);
  };

  const sendNotification = async () => {
    if (!customerId || !title || !message) return alert("Please fill all fields");

    await axios.post(`${API_BASE_URL}/api/admin/notify`, {
      customerId, title, message
    }, {
      headers: { Authorization: `Bearer ${admin.token}` }
    });

    alert("✅ Notification sent successfully");
    setTitle("");
    setMessage("");
    fetchNotifications();
  };

  return (
    <div className="max-w-5xl mx-auto mt-10">

      {/* Send Notification Card */}
      <div className="bg-white p-6 rounded-xl shadow border border-black/10 mb-10">
        <h2 className="text-2xl font-bold mb-4 text-black">Send Notification</h2>

        <label className="block mb-2 font-medium text-black">Select Customer</label>
        <select
          value={customerId}
          onChange={(e) => setCustomerId(e.target.value)}
          className="border p-2 rounded w-full mb-4"
        >
          <option value="">Select...</option>
          {customers.map(c => (
            <option key={c._id} value={c._id}>
              {c.name} ({c.email})
            </option>
          ))}
        </select>

        <label className="block mb-2 font-medium text-black">Title</label>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="border p-2 rounded w-full mb-4"
          placeholder="Enter title"
        />

        <label className="block mb-2 font-medium text-black">Message</label>
        <textarea
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          className="border p-2 rounded w-full mb-4"
          placeholder="Enter message"
        />

        <button
          onClick={sendNotification}
          className="bg-black text-white px-4 py-2 rounded w-full"
        >
          Send Notification
        </button>
      </div>

      {/* Notifications Table */}
      <div className="bg-white p-6 rounded-xl shadow border border-black/10">
        <h2 className="text-2xl font-bold text-black mb-4">Sent Notifications</h2>

        {notifications.length === 0 ? (
          <p className="text-center text-gray-500">No notifications sent yet.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full border border-black/20 text-left">
              <thead className="bg-black text-white">
                <tr>
                  <th className="p-3 border border-black/20">Customer</th>
                  <th className="p-3 border border-black/20">Title</th>
                  <th className="p-3 border border-black/20">Message</th>
                  <th className="p-3 border border-black/20">Sent At</th>
                </tr>
              </thead>
              <tbody>
                {notifications.map((n) => (
                  <tr key={n._id} className="hover:bg-gray-100 transition">
                    <td className="p-3 border border-black/10">
                      <div className="font-semibold">{n.user?.name}</div>
                      <div className="text-sm text-gray-600">{n.user?.email}</div>
                    </td>
                    <td className="p-3 border border-black/10">{n.title}</td>
                    <td className="p-3 border border-black/10">{n.message}</td>
                    <td className="p-3 border border-black/10">
                      {new Date(n.createdAt).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

    </div>
  );
}
