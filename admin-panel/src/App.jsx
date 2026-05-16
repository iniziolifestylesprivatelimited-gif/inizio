// src/App.jsx
import { Routes, Route, Navigate } from "react-router-dom";
import AdminLayout from "./layouts/AdminLayout/AdminLayout";
import Dashboard from "./components/pages/sidebarpages/Dashboard";
import Settings from "./components/pages/sidebarpages/Settings";
import Users from "./components/pages/sidebarpages/Users";
import Reports from "./components/pages/sidebarpages/Reports";
import Orders from "./components/pages/sidebarpages/Orders";
import Brands from "./components/pages/sidebarpages/Brands";
import Categories from "./components/pages/sidebarpages/Categories";
import Products from "./components/pages/sidebarpages/Products";
import Login from "./components/pages/auth/Login";
import ProtectedRoute from "./components/ProtectedRoute";
import Banners from "./components/pages/sidebarpages/Banners";
import Messages from "./components/pages/sidebarpages/Messages"
import Notifications from "./components/pages/sidebarpages/Notifications"
import TermsandConditions from "./components/pages/sidebarpages/TermsandConditions";
import Privacy from "./components/pages/sidebarpages/Privacy";
import Faqs from "./components/pages/sidebarpages/Faqs";

export default function App() {
  return (
    <Routes>
      {/* Default redirect */}
      <Route path="/" element={<Navigate to="/login" />} />

      {/* Public Route */}
      <Route path="/login" element={<Login />} />

      {/* Protected Admin Routes */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route path="dashboard" element={<Dashboard />} />
        <Route path="settings" element={<Settings />} />
        <Route path="users" element={<Users />} />
        <Route path="reports" element={<Reports />} />
        <Route path="orders" element={<Orders />} />
        <Route path="banners" element={<Banners />} />
        <Route path="messages" element={<Messages />} />
        <Route path="notifications" element={<Notifications />} />
        <Route path="settings/terms" element={<TermsandConditions />} />
        <Route path="settings/privacy" element={<Privacy />} />
        <Route path="settings/faqs" element={<Faqs />} />

        {/* Product Routes */}
        <Route path="products/brands" element={<Brands />} />
        <Route path="products/categories" element={<Categories />} />
        <Route path="products/list" element={<Products />} />
      </Route>
    </Routes>
  );
}
