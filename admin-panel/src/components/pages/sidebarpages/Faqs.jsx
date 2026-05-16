import { useEffect, useState } from "react";
import api from "../../../lib/axios";
import { useAuth } from "../../../context/AuthContext";

export default function Faqs() {
  const { admin } = useAuth();

  const [faqs, setFaqs] = useState([]);
  const [loading, setLoading] = useState(true);

  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const [editingId, setEditingId] = useState(null);
  const [saving, setSaving] = useState(false);

  // Load FAQs
  const fetchFaqs = async () => {
    try {
      const { data } = await api.get("/api/faqs");
      setFaqs(data || []);
    } catch (error) {
      console.error("❌ Error loading FAQs:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFaqs();
  }, []);

  // Save / Update FAQ
  const handleSave = async () => {
    if (!question.trim() || !answer.trim()) {
      alert("Please enter both question and answer.");
      return;
    }

    try {
      setSaving(true);

      if (editingId) {
        // Update FAQ
        await api.put(`/api/faqs/${editingId}`, { question, answer });
        alert("FAQ updated successfully!");
      } else {
        // Create FAQ
        await api.post("/api/faqs", { question, answer });
        alert("FAQ added successfully!");
      }

      setQuestion("");
      setAnswer("");
      setEditingId(null);
      fetchFaqs();
    } catch (error) {
      console.error("❌ Error saving FAQ:", error);
      alert("Failed to save FAQ.");
    } finally {
      setSaving(false);
    }
  };

  // Edit button click
  const handleEdit = (faq) => {
    setQuestion(faq.question);
    setAnswer(faq.answer);
    setEditingId(faq._id);
  };

  // Delete FAQ
  const handleDelete = async (id) => {
    if (!confirm("Are you sure you want to delete this FAQ?")) return;

    try {
      await api.delete(`/api/faqs/${id}`);
      alert("FAQ deleted successfully!");
      fetchFaqs();
    } catch (error) {
      console.error("❌ Delete error:", error);
      alert("Failed to delete FAQ.");
    }
  };

  return (
    <div className="bg-white p-6 rounded-xl shadow max-w-5xl mx-auto">
      <h2 className="text-2xl font-bold mb-4 text-black">FAQs</h2>

      {/* FAQ Form */}
      <div className="mb-6">
        <label className="block text-black mb-1 font-semibold">Question</label>
        <input
          value={question}
          onChange={(e) => setQuestion(e.target.value)}
          className="w-full border border-black rounded p-3 focus:outline-none text-black"
          placeholder="Enter question"
        />

        <label className="block text-black mt-4 mb-1 font-semibold">Answer</label>
        <textarea
          value={answer}
          onChange={(e) => setAnswer(e.target.value)}
          className="w-full border border-black rounded p-3 h-32 focus:outline-none text-black"
          placeholder="Enter answer"
        />

        <button
          onClick={handleSave}
          disabled={saving}
          className="mt-4 w-full bg-black text-white py-2 rounded hover:bg-gray-800 disabled:opacity-50"
        >
          {saving ? "Saving..." : editingId ? "Update FAQ" : "Add FAQ"}
        </button>
      </div>

      {/* FAQ List */}
      <h3 className="text-xl font-bold text-black mb-2">All FAQs</h3>

      {loading ? (
        <p className="text-gray-600">Loading...</p>
      ) : faqs.length === 0 ? (
        <p className="text-gray-600">No FAQs found.</p>
      ) : (
        <div className="space-y-4">
          {faqs.map((faq) => (
            <div
              key={faq._id}
              className="border border-black rounded p-4 flex flex-col sm:flex-row sm:justify-between sm:items-center"
            >
              <div>
                <p className="font-semibold text-black">{faq.question}</p>
                <p className="text-gray-700">{faq.answer}</p>
              </div>

              <div className="flex gap-2 mt-3 sm:mt-0">
                <button
                  onClick={() => handleEdit(faq)}
                  className="px-4 py-1 bg-black text-white rounded hover:bg-gray-800"
                >
                  Edit
                </button>

                <button
                  onClick={() => handleDelete(faq._id)}
                  className="px-4 py-1 bg-red-600 text-white rounded hover:bg-red-700"
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
