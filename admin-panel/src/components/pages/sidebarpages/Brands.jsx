// src/components/pages/sidebarpages/Brands.jsx

import { useState, useEffect } from "react";
import * as XLSX from "xlsx";
import { useAuth } from "../../../context/AuthContext";
import { API_BASE_URL } from "../../../config/constants";
import api from "@/lib/axios"; // ✅ using axios instance

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

export default function Brands() {
  const [brands, setBrands] = useState([]);
  const [loading, setLoading] = useState(true);

  const [open, setOpen] = useState(false);
  const [editBrand, setEditBrand] = useState(null);

  const [form, setForm] = useState({ name: "", description: "" });
  const [logo, setLogo] = useState(null);
  const [preview, setPreview] = useState(null);

  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const perPage = 5;

  useAuth(); // kept for any auth UI

  // ✅ Fetch brands
  useEffect(() => {
    api.get(`/api/brands`).then((res) => {
      setBrands(res.data);
      setLoading(false);
    });
  }, []);

  // ✅ Filter + Pagination
  const filtered = brands.filter((b) =>
    b.name.toLowerCase().includes(search.toLowerCase())
  );
  const totalPages = Math.ceil(filtered.length / perPage);
  const pageData = filtered.slice((page - 1) * perPage, page * perPage);

  // ✅ Open sheet (create/edit)
  const openSheet = (brand = null) => {
    setEditBrand(brand);
    setForm({
      name: brand?.name || "",
      description: brand?.description || "",
    });
    setPreview(brand?.logo ? `${API_BASE_URL}/${brand.logo}` : null);
    setLogo(null);
    setOpen(true);
  };

  // ✅ Save brand
  const saveBrand = async (e) => {
    e.preventDefault();
    const data = new FormData();
    data.append("name", form.name);
    data.append("description", form.description);
    if (logo) data.append("logo", logo);

    if (editBrand) {
      await api.put(`/api/brands/${editBrand._id}`, data);
    } else {
      await api.post(`/api/brands`, data);
    }

    setOpen(false);
    const res = await api.get(`/api/brands`);
    setBrands(res.data);
  };

  // ✅ Delete brand
  const deleteBrand = async (id) => {
    if (!confirm("Delete this brand?")) return;
    await api.delete(`/api/brands/${id}`);
    setBrands(brands.filter((b) => b._id !== id));
  };

  // ✅ Export to Excel
  const exportExcel = () => {
    const ws = XLSX.utils.json_to_sheet(
      brands.map((b) => ({
        Name: b.name,
        Description: b.description,
        Logo: b.logo,
        Active: b.isActive ? "Yes" : "No",
      }))
    );
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Brands");
    XLSX.writeFile(wb, "brands.xlsx");
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
        await api.post(`/api/brands`, {
          name: r.Name,
          description: r.Description || "",
        });
      }

      const res = await api.get(`/api/brands`);
      setBrands(res.data);
    };

    reader.readAsArrayBuffer(file);
  };

  if (loading) return <p className="p-6">Loading...</p>;

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">
      {/* ✅ Header */}
      <div className="flex justify-between mb-6">
        <h2 className="text-xl font-semibold">Brands</h2>

        <div className="flex items-center gap-3">
          {/* Import */}
          <Label className="cursor-pointer flex items-center gap-2 border px-3 py-2 rounded hover:bg-gray-100">
            <Upload size={18} />
            Import
            <Input type="file" accept=".xlsx" hidden onChange={importExcel} />
          </Label>

          {/* Export */}
          <Button variant="outline" className="flex gap-2" onClick={exportExcel}>
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
        placeholder="Search brand..."
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
              <TableHead>Logo</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Description</TableHead>
              <TableHead className="text-center">Active</TableHead>
              <TableHead className="text-center">Actions</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {pageData.map((b) => (
              <TableRow key={b._id} className="hover:bg-gray-50">
                <TableCell>
                  {b.logo ? (
                    <img
                      src={`${API_BASE_URL}/${b.logo}`}
                      className="h-12 w-12 object-contain border rounded"
                    />
                  ) : (
                    <ImageIcon className="text-gray-400" />
                  )}
                </TableCell>

                <TableCell>{b.name}</TableCell>
                <TableCell className="text-gray-600">
                  {b.description || <i>No description</i>}
                </TableCell>

                <TableCell className="text-center">
                  {b.isActive ? "Yes" : "No"}
                </TableCell>

                <TableCell className="text-center">
                  <div className="flex justify-center gap-4">
                    <Edit size={18} className="cursor-pointer" onClick={() => openSheet(b)} />
                    <Trash size={18} className="cursor-pointer text-red-500" onClick={() => deleteBrand(b._id)} />
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

      {/* ✅ Right Panel Form */}
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent side="right" className="w-[600px] p-6">
          <SheetHeader>
            <SheetTitle>{editBrand ? "Edit Brand" : "Add Brand"}</SheetTitle>
          </SheetHeader>

          <form onSubmit={saveBrand} className="space-y-4 mt-6">
            <div>
              <Label>Brand Name</Label>
              <Input
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                required
              />
            </div>

            <div>
              <Label>Description</Label>
              <Textarea
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
              />
            </div>

            <div>
              <Label>Logo</Label>
              <Input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  setLogo(e.target.files[0]);
                  setPreview(URL.createObjectURL(e.target.files[0]));
                }}
              />
            </div>

            {preview && <img src={preview} className="h-24 border rounded object-contain" />}

            <Button type="submit" className="w-full">
              {editBrand ? "Update Brand" : "Create Brand"}
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
