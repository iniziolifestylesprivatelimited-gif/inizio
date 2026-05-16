import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import {
  Home,
  Settings,
  Users,
  Flag,
  BarChart2,
  ListOrdered,
  Package,
  ChevronDown,
  ChevronRight,
  X,
  FileText,
  Shield,
  HelpCircle,
} from "lucide-react";

export default function Sidebar({ isOpen, closeSidebar }) {
  const location = useLocation();
  const [productOpen, setProductOpen] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);

  const menuItems = [
    { label: "Dashboard", icon: <Home size={20} />, path: "/dashboard" },
    { label: "Users", icon: <Users size={20} />, path: "/users" },
    { label: "Orders", icon: <ListOrdered size={20} />, path: "/orders" },
    { label: "Reports", icon: <BarChart2 size={20} />, path: "/reports" },
    { label: "Banners", icon: <Flag size={20} />, path: "/banners" },
    { label: "Messages", icon: <Flag size={20} />, path: "/messages" },
    { label: "Notifications", icon: <Flag size={20} />, path: "/notifications" },
  ];

  const productMenu = [
    { label: "Brands", path: "/products/brands" },
    { label: "Categories", path: "/products/categories" },
    { label: "Products", path: "/products/list" },
  ];

  const settingsMenu = [
    { label: "Terms & Conditions", path: "/settings/terms" },
    { label: "Privacy Policy", path: "/settings/privacy" },
    { label: "FAQs", path: "/settings/faqs" },
  ];

  const linkClasses = (path) =>
    `flex items-center gap-3 p-2 rounded-lg cursor-pointer hover:bg-gray-800 ${
      location.pathname === path ? "bg-gray-900" : ""
    }`;

  return (
    <>
      {/* Desktop Sidebar */}
      <div
        className={`hidden md:flex flex-col bg-black text-white w-56 fixed h-full top-0 left-0 shadow-xl transition-transform duration-300 
        ${isOpen ? "translate-x-0" : "-translate-x-56"}`}
      >
        <div className="mt-20 flex flex-col gap-2 px-3">
          {/* Dashboard + Users */}
          {menuItems.slice(0, 2).map((item, i) => (
            <Link key={i} to={item.path} className={linkClasses(item.path)}>
              {item.icon}
              <span>{item.label}</span>
            </Link>
          ))}

          {/* ✅ Products Dropdown */}
          <div>
            <button
              onClick={() => setProductOpen(!productOpen)}
              className="flex items-center w-full gap-3 p-2 hover:bg-gray-800 rounded-lg"
            >
              <Package size={20} />
              <span>Products</span>
              {productOpen ? <ChevronDown size={18} /> : <ChevronRight size={18} />}
            </button>

            {productOpen && (
              <div className="ml-6 mt-2 flex flex-col gap-2">
                {productMenu.map((item, i) => (
                  <Link
                    key={i}
                    to={item.path}
                    className={`text-sm p-2 rounded hover:bg-gray-800 ${
                      location.pathname === item.path
                        ? "bg-gray-900 text-white"
                        : "text-gray-300"
                    }`}
                  >
                    {item.label}
                  </Link>
                ))}
              </div>
            )}
          </div>

          {/* Remaining Menu Items (excluding settings for dropdown) */}
          {menuItems.slice(2).map((item, i) => (
            <Link key={i} to={item.path} className={linkClasses(item.path)}>
              {item.icon}
              <span>{item.label}</span>
            </Link>
          ))}

          {/* ✅ Settings Dropdown */}
          <div>
            <button
              onClick={() => setSettingsOpen(!settingsOpen)}
              className="flex items-center w-full gap-3 p-2 hover:bg-gray-800 rounded-lg"
            >
              <Settings size={20} />
              <span>Settings</span>
              {settingsOpen ? <ChevronDown size={18} /> : <ChevronRight size={18} />}
            </button>

            {settingsOpen && (
              <div className="ml-6 mt-2 flex flex-col gap-2">
                {settingsMenu.map((item, i) => (
                  <Link
                    key={i}
                    to={item.path}
                    className={`text-sm p-2 rounded hover:bg-gray-800 ${
                      location.pathname === item.path
                        ? "bg-gray-900 text-white"
                        : "text-gray-300"
                    }`}
                  >
                    {item.label}
                  </Link>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Mobile Sidebar */}
      <div
        className={`md:hidden fixed top-0 left-0 h-full bg-black text-white w-56 z-50 p-4 shadow-xl transition-transform duration-300 
        ${isOpen ? "translate-x-0" : "-translate-x-56"}`}
      >
        <button className="mb-6 text-white" onClick={closeSidebar}>
          <X size={26} />
        </button>

        <div className="flex flex-col gap-4">
          {menuItems.slice(0, 2).map((item, i) => (
            <Link key={i} to={item.path} onClick={closeSidebar} className={linkClasses(item.path)}>
              {item.icon}
              {item.label}
            </Link>
          ))}

          {/* ✅ Products Dropdown */}
          <button
            onClick={() => setProductOpen(!productOpen)}
            className="flex gap-2 items-center hover:bg-gray-800 p-2 rounded"
          >
            <Package size={20} />
            Products {productOpen ? <ChevronDown size={18} /> : <ChevronRight size={18} />}
          </button>

          {productOpen && (
            <div className="ml-6 flex flex-col gap-2">
              {productMenu.map((item, i) => (
                <Link
                  key={i}
                  to={item.path}
                  onClick={closeSidebar}
                  className="text-sm p-2 rounded hover:bg-gray-800"
                >
                  {item.label}
                </Link>
              ))}
            </div>
          )}

          {/* Remaining Items (excluding settings) */}
          {menuItems.slice(2).map((item, i) => (
            <Link key={i} to={item.path} onClick={closeSidebar} className={linkClasses(item.path)}>
              {item.icon}
              {item.label}
            </Link>
          ))}

          {/* ✅ Settings Dropdown */}
          <button
            onClick={() => setSettingsOpen(!settingsOpen)}
            className="flex gap-2 items-center hover:bg-gray-800 p-2 rounded"
          >
            <Settings size={20} />
            Settings {settingsOpen ? <ChevronDown size={18} /> : <ChevronRight size={18} />}
          </button>

          {settingsOpen && (
            <div className="ml-6 flex flex-col gap-2">
              {settingsMenu.map((item, i) => (
                <Link
                  key={i}
                  to={item.path}
                  onClick={closeSidebar}
                  className="text-sm p-2 rounded hover:bg-gray-800"
                >
                  {item.label}
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </>
  );
}
