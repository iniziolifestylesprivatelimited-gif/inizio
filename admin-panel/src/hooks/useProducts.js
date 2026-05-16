// src/hooks/useProducts.js

import { useEffect, useState } from "react";
import api from "@/lib/axios"; // ✅ use axios instance
import { API_BASE_URL } from "../config/constants";

export function useProducts() {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [brands, setBrands] = useState([]);
  const [loading, setLoading] = useState(true);

  const [open, setOpen] = useState(false);
  const [editProduct, setEditProduct] = useState(null);
  const [search, setSearch] = useState("");

  const [form, setForm] = useState({
    name: "",
    description: "",
    basePrice: "",
    offerPrice: "",
    category: "",
    brand: "",
    totalQuantity: "",
  });

  const [productImagesFiles, setProductImagesFiles] = useState([]);
  const [productImagesUrls, setProductImagesUrls] = useState("");

  const [variants, setVariants] = useState([]);

  // ✅ Load Initial Data
  useEffect(() => {
    const loadData = async () => {
      const [p, c, b] = await Promise.all([
        api.get(`/api/products`),
        api.get(`/api/categories`),
        api.get(`/api/brands`),
      ]);

      setProducts(p.data);
      setCategories(c.data);
      setBrands(b.data);
      setLoading(false);
    };

    loadData();
  }, []);

  const resetForm = () => {
    setEditProduct(null);
    setForm({
      name: "",
      description: "",
      basePrice: "",
      offerPrice: "",
      category: "",
      brand: "",
      totalQuantity: "",
    });
    setProductImagesFiles([]);
    setProductImagesUrls("");
    setVariants([]);
  };

  const convertToFullUrl = (path) =>
    path.startsWith("http") ? path : `${API_BASE_URL}/${path}`;

  const openSheet = (product = null) => {
    if (!product) {
      resetForm();
      return setOpen(true);
    }

    setEditProduct(product);

    setForm({
      name: product.name || "",
      description: product.description || "",
      basePrice: product.basePrice || "",
      offerPrice: product.offerPrice || "",
      category: product.category?._id || product.category || "",
      brand: product.brand?._id || product.brand || "",
      totalQuantity: product.totalQuantity ?? "",
    });

    setProductImagesUrls((product.images || []).map(convertToFullUrl).join(", "));

    setVariants(
      (product.variants || []).map((v) => ({
        name: v.name || "",
        quantity: v.quantity ?? "",
        price: v.price ?? "",
        offerPrice: v.offerPrice ?? "",
        imagesUrls: (v.images || []).map(convertToFullUrl).join(", "),
        imagesFiles: [],
      }))
    );

    setOpen(true);
  };

  const saveProduct = async (e) => {
    e.preventDefault();

    const data = new FormData();

    Object.entries(form).forEach(([key, val]) => val && data.append(key, val));

    productImagesFiles.forEach((f) => data.append("images", f));

    const variantPayload = variants.map((v) => ({
      name: v.name,
      quantity: Number(v.quantity || 0),
      price: Number(v.price || 0),
      offerPrice: Number(v.offerPrice || 0),
      images: v.imagesUrls.split(",").map((x) => x.trim()).filter(Boolean),
    }));

    data.append("variants", JSON.stringify(variantPayload));

    if (editProduct) {
      await api.put(`/api/products/${editProduct._id}`, data);
    } else {
      await api.post(`/api/products`, data);
    }

    setOpen(false);

    // Refresh list
    const updated = await api.get(`/api/products`);
    setProducts(updated.data);
  };

  const deleteProduct = async (id) => {
    if (!confirm("Delete this product?")) return;
    await api.delete(`/api/products/${id}`);
    setProducts((prev) => prev.filter((p) => p._id !== id));
  };

  const filteredProducts = products.filter((p) =>
    p.name.toLowerCase().includes(search.toLowerCase())
  );

  return {
    loading,
    products: filteredProducts,
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
  };
}
