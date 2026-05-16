// src/components/ProtectedRoute.jsx
import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute({ children }) {
  const { admin, loading } = useAuth();

  // ✅ Wait until AuthContext finishes loading state
  if (loading) {
    return (
      <div className="p-6 text-center text-gray-600">
        Checking authentication...
      </div>
    );
  }

  // ✅ After loading -> validate admin
  if (!admin) {
    return <Navigate to="/login" replace />;
  }

  return children;
}
