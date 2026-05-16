// src/components/pages/sidebarpages/Banners.jsx

import { useState, useEffect } from "react";
import api from "@/lib/axios"; // ✅ use axios instance
import { API_BASE_URL } from "../../../config/constants";
import { useAuth } from "../../../context/AuthContext";

// ShadCN UI
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

import { Plus, Edit, Trash, ImageIcon } from "lucide-react";

export default function Banners() {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);

  const [open, setOpen] = useState(false);
  const [editBanner, setEditBanner] = useState(null);

  const [form, setForm] = useState({
    title: "",
    link: "",
    position: "homepage",
    isActive: true,
  });

  const [image, setImage] = useState(null);
  const [preview, setPreview] = useState(null);

  // ✅ Fetch banners
  useEffect(() => {
    api.get("/api/banners").then((res) => {
      setBanners(res.data);
      setLoading(false);
    });
  }, []);

  const openSheetForm = (banner = null) => {
    setEditBanner(banner);
    setForm({
      title: banner?.title || "",
      link: banner?.link || "",
      position: banner?.position || "homepage",
      isActive: banner?.isActive ?? true,
    });
    setPreview(banner?.image ? `${API_BASE_URL}/${banner.image}` : null);
    setImage(null);
    setOpen(true);
  };

  const saveBanner = async (e) => {
    e.preventDefault();
    const data = new FormData();

    Object.entries(form).forEach(([key, val]) => data.append(key, val));
    if (image) data.append("image", image);

    if (editBanner) {
      await api.put(`/api/banners/${editBanner._id}`, data);
    } else {
      await api.post(`/api/banners`, data);
    }

    setOpen(false);
    const res = await api.get(`/api/banners`);
    setBanners(res.data);
  };

  const deleteBanner = async (id) => {
    if (!confirm("Delete this banner?")) return;
    await api.delete(`/api/banners/${id}`);
    setBanners(banners.filter((b) => b._id !== id));
  };

  if (loading) return <p className="p-6">Loading...</p>;

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">

      {/* Header */}
      <div className="flex justify-between mb-6">
        <h2 className="text-xl font-semibold">Banners</h2>
        <Button onClick={() => openSheetForm()} className="flex gap-2">
          <Plus size={18} /> Add Banner
        </Button>
      </div>

      {/* Table */}
     {/* Responsive Table / Card Layout */}
<div className="border rounded-md overflow-hidden">

  {/* Desktop Table */}
  <div className="hidden md:block overflow-x-auto">
    <Table className="w-full">
      <TableHeader>
        <TableRow>
          <TableHead>Preview</TableHead>
          <TableHead>Title</TableHead>
          <TableHead>Link</TableHead>
          <TableHead>Position</TableHead>
          <TableHead className="text-center">Active</TableHead>
          <TableHead className="text-center">Actions</TableHead>
        </TableRow>
      </TableHeader>

      <TableBody>
        {banners.map((b) => (
          <TableRow key={b._id} className="hover:bg-gray-50">
            <TableCell>
              {b.image ? (
                <img
                  src={`${API_BASE_URL}/${b.image}`}
                  className="h-12 w-28 object-cover border rounded"
                />
              ) : (
                <ImageIcon className="text-gray-400" />
              )}
            </TableCell>

            <TableCell>{b.title}</TableCell>
            <TableCell className="text-blue-600">{b.link || "-"}</TableCell>
            <TableCell className="capitalize">{b.position}</TableCell>

            <TableCell className="text-center">
              {b.isActive ? "Yes" : "No"}
            </TableCell>

            <TableCell className="text-center">
              <div className="flex justify-center gap-4">
                <Edit size={18} className="cursor-pointer" onClick={() => openSheetForm(b)} />
                <Trash size={18} className="cursor-pointer text-red-500" onClick={() => deleteBanner(b._id)} />
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  </div>

  {/* Mobile Card View */}
  <div className="block md:hidden space-y-4">
    {banners.map((b) => (
      <div key={b._id} className="border rounded-lg p-3 shadow-sm">
        <div className="flex items-center gap-3">
          {b.image ? (
            <img src={`${API_BASE_URL}/${b.image}`} className="h-16 w-32 object-cover rounded border" />
          ) : (
            <ImageIcon className="text-gray-400" />
          )}
        </div>

        <div className="mt-3 space-y-1 text-sm">
          <p><strong>Title:</strong> {b.title}</p>
          <p><strong>Link:</strong> {b.link || "-"}</p>
          <p><strong>Position:</strong> {b.position}</p>
          <p><strong>Active:</strong> {b.isActive ? "Yes" : "No"}</p>
        </div>

        <div className="flex justify-end gap-4 mt-3">
          <Edit size={18} className="cursor-pointer" onClick={() => openSheetForm(b)} />
          <Trash size={18} className="cursor-pointer text-red-500" onClick={() => deleteBanner(b._id)} />
        </div>
      </div>
    ))}
  </div>

</div>


      {/* Sheet Form */}
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent side="right" className="w-[500px] p-6">
          <SheetHeader>
            <SheetTitle>{editBanner ? "Edit Banner" : "Add Banner"}</SheetTitle>
          </SheetHeader>

          <form onSubmit={saveBanner} className="space-y-4 mt-6">
            <div>
              <Label>Title</Label>
              <Input
                value={form.title}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
                required
              />
            </div>

            <div>
              <Label>Link (Optional)</Label>
              <Input
                value={form.link}
                onChange={(e) => setForm({ ...form, link: e.target.value })}
              />
            </div>

            <div>
              <Label>Position</Label>
              <select
                className="border rounded p-2 w-full"
                value={form.position}
                onChange={(e) => setForm({ ...form, position: e.target.value })}
              >
                <option value="homepage">Homepage</option>
                <option value="category">Category Page</option>
                <option value="offers">Offers Section</option>
              </select>
            </div>

            <div>
              <Label>Banner Image</Label>
              <Input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  setImage(e.target.files[0]);
                  setPreview(URL.createObjectURL(e.target.files[0]));
                }}
              />
            </div>

            {preview && (
              <img
                src={preview}
                className="h-24 w-full object-cover rounded border"
              />
            )}

            <Button type="submit" className="w-full">
              {editBanner ? "Update Banner" : "Create Banner"}
            </Button>

            <SheetClose asChild>
              <Button variant="ghost" className="w-full">
                Cancel
              </Button>
            </SheetClose>
          </form>
        </SheetContent>
      </Sheet>
    </div>
  );
}
