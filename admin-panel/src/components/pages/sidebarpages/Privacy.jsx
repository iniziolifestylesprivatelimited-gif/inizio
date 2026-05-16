import { useEffect, useState } from "react";
import api from "../../../lib/axios"; // your axios instance
import { useAuth } from "../../../context/AuthContext";

export default function Privacy() {
  const { admin } = useAuth();
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // ✅ Fetch existing Privacy Policy
  useEffect(() => {
    const fetchPrivacy = async () => {
      try {
        const { data } = await api.get("/api/privacy");
        setContent(data?.content || "");
      } catch (error) {
        console.error("❌ Error fetching privacy policy:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchPrivacy();
  }, []);

  // ✅ Save/Update Privacy Policy
  const handleSave = async () => {
    if (!content.trim()) {
      alert("Please enter Privacy Policy text before saving.");
      return;
    }

    try {
      setSaving(true);
      await api.post("/api/privacy", { content });
      alert("✅ Privacy Policy updated successfully!");
    } catch (error) {
      console.error("❌ Error saving privacy policy:", error);
      alert("Failed to update Privacy Policy. Check console for details.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white p-6 rounded-xl shadow">
        <h2 className="text-xl font-bold mb-2">Privacy Policy</h2>
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="bg-white p-6 rounded-xl shadow">
      <h2 className="text-xl font-bold mb-4">Privacy Policy</h2>
      <p className="text-gray-500 mb-3">
        Update the Privacy Policy text that users will see in the app.
      </p>

      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        className="w-full h-96 border border-gray-300 rounded-md p-3 focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800"
        placeholder="Write your Privacy Policy here..."
      />

      <button
        onClick={handleSave}
        disabled={saving}
        className="mt-4 bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {saving ? "Saving..." : "Save Changes"}
      </button>
    </div>
  );
}
