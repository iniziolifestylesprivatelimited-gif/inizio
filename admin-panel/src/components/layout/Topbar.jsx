import { useState, useRef, useEffect } from "react";
import { Bell, Menu, LogOut } from "lucide-react";
import { useAuth } from "../../context/AuthContext";
import { useNavigate } from "react-router-dom";

export default function Topbar({ toggleSidebar }) {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);
  const { admin, logout } = useAuth();
  const navigate = useNavigate();

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <header className="h-16 bg-white shadow-sm flex items-center justify-between px-6 sticky top-0 z-40">
      {/* Left side - logo + menu */}
      <div className="flex items-center gap-3">
        <button className="md:hidden" onClick={toggleSidebar}>
          <Menu size={26} />
        </button>

        <span className="text-xl font-bold tracking-wide">LOGO</span>
        <h2 className="text-lg font-semibold hidden sm:block text-gray-600">
          Admin Panel
        </h2>
      </div>

      {/* Right side - notifications + profile */}
      <div className="flex items-center gap-4 relative" ref={dropdownRef}>
        <Bell className="cursor-pointer text-gray-700 hover:text-black" />

        {/* Profile circle */}
        <div
          className="w-10 h-10 rounded-full bg-gray-300 cursor-pointer shadow-inner flex items-center justify-center"
          onClick={() => setDropdownOpen(!dropdownOpen)}
        >
          <span className="text-sm font-semibold text-gray-700">
            {admin?.name?.[0]?.toUpperCase() || "A"}
          </span>
        </div>

        {/* Dropdown */}
        {dropdownOpen && (
          <div className="absolute right-0 top-12 bg-white shadow-lg rounded-lg w-44 border border-gray-100 animate-fadeIn">
            <div className="px-4 py-3 border-b">
              <p className="text-sm font-semibold text-gray-800">
                {admin?.name || "Admin"}
              </p>
              <p className="text-xs text-gray-500 truncate">
                {admin?.email || "admin@example.com"}
              </p>
            </div>

            <button
              onClick={handleLogout}
              className="flex items-center gap-2 w-full px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
            >
              <LogOut size={16} /> Logout
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
