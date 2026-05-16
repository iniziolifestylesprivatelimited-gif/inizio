// src/components/pages/sidebarpages/Users.jsx

import { useEffect, useState } from "react";
import api from "@/lib/axios"; // ✅ use axios instance
import { API_BASE_URL } from "../../../config/constants";
import { useAuth } from "../../../context/AuthContext";

import {
  CheckCircle,
  XCircle,
  FileText,
  Eye,
  ChevronLeft,
  ChevronRight,
  Search,
  ArrowUpDown,
} from "lucide-react";

export default function Users() {
  const [customers, setCustomers] = useState([]);
  const [filtered, setFiltered] = useState([]);

  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const [sortField, setSortField] = useState(null);
  const [sortAsc, setSortAsc] = useState(true);

  const [page, setPage] = useState(1);
  const perPage = 5;

  const [modalUser, setModalUser] = useState(null);
  const [gstModal, setGstModal] = useState(null);

  useAuth(); // still needed for auth context if used anywhere else

  const fetchUsers = async () => {
    try {
      const res = await api.get(`/api/admin/customers`);
      setCustomers(res.data);
      setFiltered(res.data);
    } catch (err) {
      console.error("Error fetching customers:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // ✅ Search Filter
  useEffect(() => {
    const s = search.toLowerCase();
    const result = customers.filter(
      (u) =>
        u.name.toLowerCase().includes(s) ||
        u.email.toLowerCase().includes(s) ||
        (u.gstNumber || "").toLowerCase().includes(s)
    );

    setFiltered(result);
    setPage(1);
  }, [search, customers]);

  // ✅ Sorting Handler
  const handleSort = (field) => {
    const asc = field === sortField ? !sortAsc : true;

    const sorted = [...filtered].sort((a, b) => {
      const valA = a[field]?.toString().toLowerCase() || "";
      const valB = b[field]?.toString().toLowerCase() || "";
      if (valA < valB) return asc ? -1 : 1;
      if (valA > valB) return asc ? 1 : -1;
      return 0;
    });

    setFiltered(sorted);
    setSortField(field);
    setSortAsc(asc);
  };

  // ✅ Approve user
  const handleApprove = async (id) => {
    try {
      await api.put(`/api/admin/approve/${id}`);
      fetchUsers();
    } catch (err) {
      alert(err.response?.data?.message || "Error approving user");
    }
  };

  // ✅ Reject user
  const handleReject = async (id) => {
    if (!confirm("Are you sure to reject & delete this user?")) return;
    try {
      await api.delete(`/api/admin/reject/${id}`);
      fetchUsers();
    } catch (err) {
      alert(err.response?.data?.message || "Error rejecting user");
    }
  };

  if (loading) return <p className="p-6">Loading users...</p>;

  // ✅ Pagination
  const totalPages = Math.ceil(filtered.length / perPage);
  const pageData = filtered.slice((page - 1) * perPage, page * perPage);

  return (
    <div className="bg-white p-6 rounded-xl shadow">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Registered Customers</h2>

        {/* ✅ Search Bar */}
        <div className="flex items-center border rounded-md px-3 py-1 bg-gray-50">
          <Search size={18} className="text-gray-500" />
          <input
            type="text"
            className="ml-2 outline-none bg-transparent"
            placeholder="Search..."
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
      </div>

      <table className="w-full border-collapse">
        <thead>
          <tr className="bg-gray-100 text-left">
            <th onClick={() => handleSort("name")} className="p-2 border cursor-pointer">
              Name <ArrowUpDown className="inline w-4" />
            </th>

            <th onClick={() => handleSort("email")} className="p-2 border cursor-pointer">
              Email <ArrowUpDown className="inline w-4" />
            </th>

            <th className="p-2 border">GST Number</th>
            <th className="p-2 border text-center">GST Doc</th>
            <th className="p-2 border text-center">Actions</th>

            <th onClick={() => handleSort("isApproved")} className="p-2 border cursor-pointer">
              Status <ArrowUpDown className="inline w-4" />
            </th>
          </tr>
        </thead>

        <tbody>
          {pageData.map((user) => (
            <tr key={user._id} className="border-b hover:bg-gray-50">
              <td className="p-2 border">{user.name}</td>
              <td className="p-2 border">{user.email}</td>
              <td className="p-2 border">{user.gstNumber || "N/A"}</td>

              {/* ✅ View GST Doc */}
              <td className="p-2 border text-center">
                {user.gstDocument ? (
                  <button onClick={() => setGstModal(user.gstDocument)} title="View GST Document">
                    <FileText className="text-blue-600 hover:text-blue-800" size={22} />
                  </button>
                ) : (
                  <span className="text-gray-400">No Doc</span>
                )}
              </td>

              {/* ✅ Actions */}
              <td className="p-2 border text-center flex justify-center gap-4">
                <button title="View Details" onClick={() => setModalUser(user)}>
                  <Eye size={22} className="text-gray-600 hover:text-black" />
                </button>

                {!user.isApproved && (
                  <button onClick={() => handleApprove(user._id)} title="Approve">
                    <CheckCircle size={24} className="text-green-600 hover:text-green-800" />
                  </button>
                )}

                <button onClick={() => handleReject(user._id)} title="Reject">
                  <XCircle size={24} className="text-red-600 hover:text-red-800" />
                </button>
              </td>

              <td className="p-2 border">
                {user.isApproved ? (
                  <span className="text-green-600 font-semibold">Approved</span>
                ) : (
                  <span className="text-red-600 font-semibold">Pending</span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* ✅ Pagination */}
      <div className="flex justify-center items-center mt-4 gap-4">
        <button disabled={page === 1} onClick={() => setPage((p) => p - 1)} className="p-2 disabled:opacity-40">
          <ChevronLeft size={24} />
        </button>

        <span className="text-gray-700">Page {page} of {totalPages}</span>

        <button disabled={page === totalPages} onClick={() => setPage((p) => p + 1)} className="p-2 disabled:opacity-40">
          <ChevronRight size={24} />
        </button>
      </div>

      {/* ✅ USER DETAILS MODAL */}
      {modalUser && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center">
          <div className="bg-white rounded-xl p-6 w-96 shadow-lg">
            <h3 className="text-xl font-bold mb-4">User Details</h3>

            <p><b>Name:</b> {modalUser.name}</p>
            <p><b>Email:</b> {modalUser.email}</p>
            <p><b>GST Number:</b> {modalUser.gstNumber || "N/A"}</p>
            <p><b>Status:</b> {modalUser.isApproved ? "Approved" : "Pending"}</p>

            <button
              onClick={() => setModalUser(null)}
              className="mt-4 w-full bg-gray-700 text-white py-2 rounded-md"
            >
              Close
            </button>
          </div>
        </div>
      )}

      {/* ✅ GST DOCUMENT VIEW MODAL */}
      {gstModal && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center">
          <div className="bg-white p-4 rounded-xl w-[80%] h-[80%] shadow-xl relative">
            <button
              className="absolute top-2 right-2 bg-red-600 text-white px-3 py-1 rounded"
              onClick={() => setGstModal(null)}
            >
              Close
            </button>

            <iframe
              src={`${API_BASE_URL}/${gstModal}`}
              className="w-full h-full rounded-lg"
            />
          </div>
        </div>
      )}
    </div>
  );
}
