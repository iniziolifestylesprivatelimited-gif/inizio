// src/components/pages/sidebarpages/Products.jsx

import { useState, useMemo } from "react";
import api from "@/lib/axios"; // ✅ Use axios instance
import { API_BASE_URL } from "../../../config/constants";

import { useProducts } from "@/hooks/useProducts";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogClose } from "@/components/ui/dialog";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import { Edit, Trash, Plus, ImageIcon, X } from "lucide-react";

export default function Products() {

  const {
    loading,
    products,
    categories,
    brands,
    form,
    setForm,
    open,
    setOpen,
    openSheet,
    saveProduct,
    deleteProduct,
    productImagesUrls,
    setProductImagesUrls,
    productImagesFiles,
    setProductImagesFiles,
    variants,
    setVariants,
    search,
    setSearch,
    editProduct,
  } = useProducts();

  const [step, setStep] = useState(1);

  const productPreviewImages = useMemo(() => {
    const urls = productImagesUrls.split(",").map((u) => u.trim()).filter(Boolean);
    const files = Array.from(productImagesFiles || []).map((f) => URL.createObjectURL(f));
    return [...urls, ...files];
  }, [productImagesUrls, productImagesFiles]);

  const variantPreviewImages = (v) => [
    ...(v.imagesUrls?.split(",").map((u) => u.trim()).filter(Boolean) || []),
    ...Array.from(v.imagesFiles || []).map((f) => URL.createObjectURL(f)),
  ];

  const addVariant = () =>
    setVariants((prev) => [...prev, { name: "", quantity: "", price: "", offerPrice: "", imagesUrls: "", imagesFiles: [] }]);

  const removeVariant = (i) => setVariants((prev) => prev.filter((_, idx) => idx !== i));

  const updateVariantField = (i, key, value) =>
    setVariants((prev) => {
      const arr = [...prev];
      arr[i] = { ...arr[i], [key]: value };
      return arr;
    });

  if (loading) return <p className="p-6">Loading...</p>;

  return (
    <div className="bg-white p-6 rounded-xl shadow-sm">

      {/* Header */}
      <div className="flex justify-between mb-4">
        <h2 className="text-xl font-bold">Products</h2>
        <div className="flex gap-3">
          <Input
            placeholder="Search products..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64"
          />

          <Button onClick={() => { setStep(1); openSheet(null); }}>
            <Plus size={18} className="mr-2" /> Add Product
          </Button>

          {/* ✅ Export Excel */}
          <Button onClick={() => (window.location.href = `${API_BASE_URL}/api/products/export/excel`)}>
            Export Excel
          </Button>

          {/* ✅ Import Excel */}
          <label className="cursor-pointer bg-black text-white px-4 py-2 rounded-md">
            Import Excel
            <input type="file" hidden accept=".xlsx,.xls"
              onChange={async (e) => {
                const file = e.target.files[0];
                if (!file) return;
                const formData = new FormData();
                formData.append("file", file);

                await api.post(`/api/products/bulk-upload`, formData); // ✅ using api instance

                alert("Products Uploaded ✅");
                window.location.reload();
              }}
            />
          </label>

        </div>
      </div>

      {/* Product Table */}
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Image</TableHead>
            <TableHead>Name</TableHead>
            <TableHead>Brand</TableHead>
            <TableHead>Category</TableHead>
            <TableHead>Price</TableHead>
            <TableHead className="text-center">Actions</TableHead>
          </TableRow>
        </TableHeader>

        <TableBody>
          {products.map((p) => {
            const variantImg = p?.variants?.[0]?.images?.[0];
            const productImg = p.images?.[0];

            const imgSrc = variantImg
              ? variantImg.startsWith("https") ? variantImg : `${API_BASE_URL}/${variantImg}`
              : productImg
              ? productImg.startsWith("https") ? productImg : `${API_BASE_URL}/${productImg}`
              : null;

            return (
              <TableRow key={p._id}>
                <TableCell>
                  {imgSrc ? (
                    <img src={imgSrc} className="h-12 w-12 object-contain border rounded" />
                  ) : (
                    <ImageIcon className="text-gray-400" />
                  )}
                </TableCell>

                <TableCell>{p.name}</TableCell>
                <TableCell>{p.brand?.name}</TableCell>
                <TableCell>{p.category?.name}</TableCell>
                <TableCell>₹{p.offerPrice || p.basePrice}</TableCell>

                <TableCell className="text-center">
                  <div className="flex justify-center gap-3">
                    <Edit size={18} className="cursor-pointer"
                      onClick={() => { setStep(1); openSheet(p); }} />
                    <Trash size={18} className="cursor-pointer text-red-500"
                      onClick={() => deleteProduct(p._id)} />
                  </div>
                </TableCell>

              </TableRow>
            );
          })}
        </TableBody>
      </Table>

      {/* FORM WIZARD */}
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="w-[95vw] max-w-[900px] max-h-[90vh] overflow-y-auto rounded-xl p-6">

          <DialogHeader>
            <DialogTitle className="text-2xl font-semibold">
              {editProduct ? "Edit Product" : "Add Product"}
            </DialogTitle>
          </DialogHeader>

          <p className="text-center text-sm text-gray-500">Step {step} of 3</p>

          {/* STEP 1 */}
          {step === 1 && (
            <div className="space-y-6 mt-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Input placeholder="Product Name" required value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })} />
                <Input type="number" placeholder="Base Price" required value={form.basePrice}
                  onChange={(e) => setForm({ ...form, basePrice: e.target.value })} />
                <Input type="number" placeholder="Offer Price" value={form.offerPrice}
                  onChange={(e) => setForm({ ...form, offerPrice: e.target.value })} />
                <Input type="number" placeholder="Total Quantity" value={form.totalQuantity}
                  onChange={(e) => setForm({ ...form, totalQuantity: e.target.value })} />
              </div>

              <Textarea placeholder="Description" value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })} />

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <select className="border p-2 rounded" value={form.category}
                  onChange={(e) => setForm({ ...form, category: e.target.value })}>
                  <option value="">Select Category</option>
                  {categories.map((c) => <option key={c._id} value={c._id}>{c.name}</option>)}
                </select>

                <select className="border p-2 rounded" value={form.brand}
                  onChange={(e) => setForm({ ...form, brand: e.target.value })}>
                  <option value="">Select Brand</option>
                  {brands.map((b) => <option key={b._id} value={b._id}>{b.name}</option>)}
                </select>
              </div>

              <div className="flex justify-end gap-3 mt-6">
                <DialogClose asChild><Button variant="ghost">Cancel</Button></DialogClose>
                <Button onClick={() => setStep(2)}>Next</Button>
              </div>
            </div>
          )}

          {/* STEP 2 */}
          {step === 2 && (
            <div className="space-y-6 mt-4">
              <Textarea placeholder="https://... , https://..." value={productImagesUrls}
                onChange={(e) => setProductImagesUrls(e.target.value)} />

              <Input type="file" multiple onChange={(e) => setProductImagesFiles(e.target.files)} />

              <div className="flex flex-wrap gap-2">
                {productPreviewImages.map((src, i) => (
                  <img key={i} src={src} className="h-16 w-16 object-cover border rounded" />
                ))}
              </div>

              <div className="flex justify-between mt-6">
                <Button variant="outline" onClick={() => setStep(1)}>Back</Button>
                <Button onClick={() => setStep(3)}>Next</Button>
              </div>
            </div>
          )}

          {/* STEP 3 — Variants */}
          {step === 3 && (
            <div className="space-y-6 mt-4">

              <div className="flex justify-between items-center">
                <Label className="font-semibold text-lg">Variants</Label>
                <Button size="sm" onClick={addVariant}>
                  <Plus size={16} className="mr-1" /> Add Variant
                </Button>
              </div>

              <div className="space-y-4">
                {variants.length === 0 && (
                  <p className="text-gray-500 text-sm text-center border rounded-md py-4">
                    No variants yet. Click <strong>Add Variant</strong>.
                  </p>
                )}

                {variants.map((v, i) => (
                  <div key={i} className="border rounded-lg p-4 space-y-4 bg-gray-50">

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <Input placeholder="Variant Name" value={v.name}
                        onChange={(e) => updateVariantField(i, "name", e.target.value)} />
                      <Input type="number" placeholder="Quantity" value={v.quantity}
                        onChange={(e) => updateVariantField(i, "quantity", e.target.value)} />
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <Input type="number" placeholder="Price" value={v.price}
                        onChange={(e) => updateVariantField(i, "price", e.target.value)} />
                      <Input type="number" placeholder="Offer Price" value={v.offerPrice}
                        onChange={(e) => updateVariantField(i, "offerPrice", e.target.value)} />
                    </div>

                    <Textarea placeholder="Image URLs (comma separated)" value={v.imagesUrls}
                      onChange={(e) => updateVariantField(i, "imagesUrls", e.target.value)} />

                    {variantPreviewImages(v).length > 0 && (
                      <div className="flex flex-wrap gap-2">
                        {variantPreviewImages(v).map((src, idx) => (
                          <img key={idx} src={src} className="h-14 w-14 rounded border object-cover" />
                        ))}
                      </div>
                    )}

                    <div className="flex justify-between items-center">
                      <div className="flex gap-2">
                        <Button size="sm" variant="outline" disabled={i === 0}
                          onClick={() => setVariants((prev) => {
                            const arr = [...prev];
                            [arr[i - 1], arr[i]] = [arr[i], arr[i - 1]];
                            return arr;
                          })}>
                          ↑
                        </Button>

                        <Button size="sm" variant="outline" disabled={i === variants.length - 1}
                          onClick={() => setVariants((prev) => {
                            const arr = [...prev];
                            [arr[i + 1], arr[i]] = [arr[i], arr[i + 1]];
                            return arr;
                          })}>
                          ↓
                        </Button>
                      </div>

                      <div className="flex gap-2">
                        <Button size="sm" variant="outline"
                          onClick={() => setVariants((prev) => [...prev, { ...v }])}>
                          Duplicate
                        </Button>

                        <Button size="sm" variant="destructive" onClick={() => removeVariant(i)}>
                          <X size={16} className="mr-1" /> Remove
                        </Button>
                      </div>
                    </div>

                  </div>
                ))}
              </div>

              <div className="flex justify-between mt-6">
                <Button variant="outline" onClick={() => setStep(2)}>Back</Button>
                <Button onClick={saveProduct}>
                  {editProduct ? "Update Product" : "Create Product"}
                </Button>
              </div>

            </div>
          )}

        </DialogContent>
      </Dialog>
    </div>
  );
}
