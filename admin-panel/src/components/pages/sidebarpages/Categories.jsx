// src/components/pages/sidebarpages/Categories.jsx

import { useState, useEffect } from "react";
import * as XLSX from "xlsx";
import { useAuth } from "../../../context/AuthContext";
import { API_BASE_URL } from "../../../config/constants";
import api from "@/lib/axios"; // ✅ Use central axios instance

// ✅ ShadCN UI
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
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

// ✅ Icons
import {
  Plus,
  Edit,
  Trash,
  Upload,
  Download,
  ImageIcon,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";

export default function Categories() {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);

  const [open, setOpen] = useState(false);
  const [editCategory, setEditCategory] = useState(null);

  const [form, setForm] = useState({ name: "", description: "" });
  const [icon, setIcon] = useState(null);
  const [preview, setPreview] = useState(null);

  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const perPage = 5;

  useAuth(); // keeping context active if UI uses it

  // ✅ Fetch categories
  useEffect(() => {
    api.get(`/api/categories`).then((res) => {
      setCategories(res.data);
      setLoading(false);
    });
  }, []);

  // ✅ Filter + paginate
  const filtered = categories.filter((c) =>
    c.name.toLowerCase().includes(search.toLowerCase())
  );
  const totalPages = Math.ceil(filtered.length / perPage);
  const pageData = filtered.slice((page - 1) * perPage, page * perPage);

  // ✅ Open Sheet (create/edit)
  const openSheet = (category = null) => {
    setEditCategory(category);
    setForm({
      name: category?.name || "",
      description: category?.description || "",
    });
    setPreview(category?.icon ? `${API_BASE_URL}/${category.icon}` : null);
    setIcon(null);
    setOpen(true);
  };

  // ✅ Save category (Create/Update)
  const saveCategory = async (e) => {
    e.preventDefault();

    const data = new FormData();
    data.append("name", form.name);
    data.append("description", form.description);
    if (icon) data.append("icon", icon);

    if (editCategory) {
      await api.put(`/api/categories/${editCategory._id}`, data);
    } else {
      await api.post(`/api/categories`, data);
    }

    setOpen(false);
    const res = await api.get(`/api/categories`);
    setCategories(res.data);
  };

  // ✅ Delete category
  const deleteCategory = async (id) => {
    if (!confirm("Are you sure?")) return;
    await api.delete(`/api/categories/${id}`);
    setCategories(categories.filter((c) => c._id !== id));
  };

  // ✅ Export to Excel
  const exportExcel = () => {
    const ws = XLSX.utils.json_to_sheet(
      categories.map((c) => ({
        Name: c.name,
        Description: c.description,
        Icon: c.icon,
        Active: c.isActive ? "Yes" : "No",
      }))
    );
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Categories");
    XLSX.writeFile(wb, "categories.xlsx");
  };

  // ✅ Import from Excel
  const importExcel = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (evt) => {
      const wb = XLSX.read(new Uint8Array(evt.target.result), { type: "array" });
      const rows = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);

      for (let r of rows) {
        const data = new FormData();
        data.append("name", r.Name);
        data.append("description", r.Description || "");

        await api.post(`/api/categories`, data);
      }

      const res = await api.get(`/api/categories`);
      setCategories(res.data);
    };

    reader.readAsArrayBuffer(file);
  };

  if (loading) return <p className="p-6">Loading...</p>;

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      {/* ✅ Header */}
      <div className="flex justify-between mb-6">
        <h2 className="text-xl font-semibold">Categories</h2>

        <div className="flex items-center gap-3">
          {/* Import */}
          <Label className="cursor-pointer flex items-center gap-2 border px-3 py-2 rounded hover:bg-gray-100">
            <Upload size={18} />
            Import
            <Input type="file" hidden accept=".xlsx" onChange={importExcel} />
          </Label>

          {/* Export */}
          <Button variant="outline" onClick={exportExcel} className="flex gap-2">
            <Download size={18} /> Export
          </Button>

          {/* Add */}
          <Button onClick={() => openSheet()} className="flex gap-2">
            <Plus size={18} /> Add
          </Button>
        </div>
      </div>

      {/* ✅ Search */}
      <Input
        placeholder="Search category..."
        className="w-64 mb-4"
        value={search}
        onChange={(e) => {
          setSearch(e.target.value);
          setPage(1);
        }}
      />

      {/* ✅ Table */}
      <div className="border rounded-md overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Icon</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Description</TableHead>
              <TableHead className="text-center">Active</TableHead>
              <TableHead className="text-center">Actions</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {pageData.map((c) => (
              <TableRow key={c._id} className="hover:bg-gray-50">
                <TableCell>
                  {c.icon ? (
                    <img
                      src={`${API_BASE_URL}/${c.icon}`}
                      className="h-12 w-12 object-contain border rounded"
                    />
                  ) : (
                    <ImageIcon className="text-gray-400" />
                  )}
                </TableCell>

                <TableCell>{c.name}</TableCell>
                <TableCell className="text-gray-600">
                  {c.description || <i>No description</i>}
                </TableCell>

                <TableCell className="text-center">
                  {c.isActive ? "Yes" : "No"}
                </TableCell>

                <TableCell className="text-center">
                  <div className="flex justify-center gap-4">
                    <Edit size={18} className="cursor-pointer" onClick={() => openSheet(c)} />
                    <Trash size={18} className="cursor-pointer text-red-500" onClick={() => deleteCategory(c._id)} />
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* ✅ Pagination */}
      <div className="flex justify-center mt-4 gap-4">
        <Button variant="outline" size="icon" disabled={page === 1} onClick={() => setPage(page - 1)}>
          <ChevronLeft />
        </Button>

        <span className="px-4 py-2">{page} / {totalPages}</span>

        <Button variant="outline" size="icon" disabled={page === totalPages} onClick={() => setPage(page + 1)}>
          <ChevronRight />
        </Button>
      </div>

      {/* ✅ Sheet */}
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent side="right" className="w-[600px] p-6">
          <SheetHeader>
            <SheetTitle>{editCategory ? "Edit Category" : "Add Category"}</SheetTitle>
          </SheetHeader>

          <form onSubmit={saveCategory} className="space-y-4 mt-6">
            <div>
              <Label>Category Name</Label>
              <Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
            </div>

            <div>
              <Label>Description</Label>
              <Textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
            </div>

            <div>
              <Label>Icon</Label>
              <Input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  setIcon(e.target.files[0]);
                  setPreview(URL.createObjectURL(e.target.files[0]));
                }}
              />
            </div>

            {preview && <img src={preview} className="h-24 border rounded object-contain" />}

            <Button type="submit" className="w-full">
              {editCategory ? "Update Category" : "Create Category"}
            </Button>

            <SheetClose asChild>
              <Button variant="ghost" className="w-full">Cancel</Button>
            </SheetClose>
          </form>
        </SheetContent>
      </Sheet>
    </div>
  );
}
