import axios from "axios";
import { API_BASE_URL } from "../config/constants";

const api = axios.create({
  baseURL: API_BASE_URL,
});

// ✅ Automatically include admin token in every request
api.interceptors.request.use((config) => {
  const adminData = localStorage.getItem("admin");

  if (adminData) {
    const admin = JSON.parse(adminData);
    if (admin?.token) {
      config.headers.Authorization = `Bearer ${admin.token}`;
    }
  }

  return config;
});

export default api;
