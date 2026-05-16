// src/components/pages/sidebarpages/Orders.jsx

import { useState, useEffect } from "react";
import api from "@/lib/axios"; // ✅ use centralized axios
import { API_BASE_URL } from "../../../config/constants";
import { useAuth } from "../../../context/AuthContext";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetClose,
} from "@/components/ui/sheet";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export default function Orders() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const [open, setOpen] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState(null);

  const [search, setSearch] = useState("");

  // ✅ Fetch all orders
  useEffect(() => {
    api.get(`/api/orders/all`).then((res) => {
      setOrders(res.data);
      setLoading(false);
    });
  }, []);

  const openSheet = (order) => {
    setSelectedOrder(order);
    setOpen(true);
  };

  const updateStatus = async () => {
    await api.put(`/api/orders/${selectedOrder._id}/status`, {
      orderStatus: selectedOrder.orderStatus,
    });

    const res = await api.get(`/api/orders/all`);
    setOrders(res.data);
    setOpen(false);
  };

  const filtered = orders.filter((o) =>
    o._id.toLowerCase().includes(search.toLowerCase())
  );

  if (loading) return <p className="p-6">Loading...</p>;

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">

      {/* Header */}
      <div className="flex justify-between mb-6">
        <h2 className="text-xl font-semibold">Orders</h2>
      </div>

      {/* Search */}
      <Input
        placeholder="Search Order ID..."
        className="w-64 mb-4"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      {/* Table */}
      <div className="border rounded-md overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Order ID</TableHead>
              <TableHead>Total</TableHead>
              <TableHead>Payment</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Date</TableHead>
              <TableHead className="text-center">Actions</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {filtered.map((o) => (
              <TableRow key={o._id} className="hover:bg-gray-50">
                <TableCell>{o._id}</TableCell>
                <TableCell>₹{o.totalAmount}</TableCell>
                <TableCell>{o.paymentMethod} ({o.paymentStatus})</TableCell>
                <TableCell>{o.orderStatus}</TableCell>
                <TableCell>{new Date(o.createdAt).toLocaleDateString()}</TableCell>
                <TableCell className="text-center">
                  <Button variant="outline" size="sm" onClick={() => openSheet(o)}>
                    View / Update
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* Sheet Drawer */}
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent side="right" className="w-[500px] p-6 overflow-y-auto">
          <SheetHeader>
            <SheetTitle>Order Details</SheetTitle>
          </SheetHeader>

          {selectedOrder && (
            <div className="space-y-4 mt-4">

              <p><b>Order ID:</b> {selectedOrder._id}</p>
              <p><b>Total:</b> ₹{selectedOrder.totalAmount}</p>

              <p>
                <b>Payment:</b> {selectedOrder.paymentMethod} ({selectedOrder.paymentStatus})
              </p>

              {/* ✅ Invoice */}
              <div className="border p-3 rounded-md bg-gray-50">
                <Label>Invoice</Label>

                {selectedOrder.invoiceUrl ? (
                  <a
                    href={`${API_BASE_URL}${selectedOrder.invoiceUrl}`}
                    target="_blank"
                    className="text-blue-600 underline block mt-1"
                  >
                    📄 Download Invoice
                  </a>
                ) : (
                  <p className="text-sm text-gray-500 mt-1">No invoice uploaded.</p>
                )}

                <input
                  type="file"
                  accept="application/pdf,image/*"
                  className="mt-2 block"
                  onChange={(e) =>
                    setSelectedOrder({ ...selectedOrder, invoiceFile: e.target.files[0] })
                  }
                />

                <Button
                  size="sm"
                  className="mt-2"
                  onClick={async () => {
                    if (!selectedOrder.invoiceFile)
                      return alert("Please choose a file first");

                    const formData = new FormData();
                    formData.append("invoice", selectedOrder.invoiceFile);

                    await api.post(`/api/admin/orders/${selectedOrder._id}/invoice`, formData);

                    alert("✅ Invoice Uploaded Successfully");

                    const refreshed = await api.get(`/api/orders/all`);
                    setOrders(refreshed.data);
                  }}
                >
                  Upload Invoice
                </Button>
              </div>

              {/* ✅ Status Update */}
              <div>
                <Label>Order Status</Label>
                <select
                  className="border rounded p-2 w-full"
                  value={selectedOrder.orderStatus}
                  onChange={(e) =>
                    setSelectedOrder({ ...selectedOrder, orderStatus: e.target.value })
                  }
                >
                  <option value="Processing">Processing</option>
                  <option value="Shipped">Shipped</option>
                  <option value="Delivered">Delivered</option>
                  <option value="Cancelled">Cancelled</option>
                </select>
              </div>

              {/* ✅ Items */}
              <div>
                <b>Items:</b>
                {selectedOrder.items.map((item, i) => (
                  <div key={i} className="text-sm border-b py-2">
                    {item.product?.name} × {item.quantity}
                  </div>
                ))}
              </div>

              {/* ✅ Address */}
              <div>
                <b>Address:</b>
                <p className="text-sm mt-1">
                  {selectedOrder.address.name}, {selectedOrder.address.phone}<br />
                  {selectedOrder.address.street}, {selectedOrder.address.city},{" "}
                  {selectedOrder.address.state} - {selectedOrder.address.pincode}
                </p>
              </div>

              <Button className="w-full" onClick={updateStatus}>
                Update Order Status
              </Button>

              <SheetClose asChild>
                <Button variant="ghost" className="w-full">Close</Button>
              </SheetClose>
            </div>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}
