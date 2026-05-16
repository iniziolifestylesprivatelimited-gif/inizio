import { useEffect, useState, useRef } from "react";
import { API_BASE_URL } from "@/config/constants";
import { useAuth } from "@/context/AuthContext";
import io from "socket.io-client";

const socket = io(API_BASE_URL, { transports: ["websocket"] });

export default function Messages() {
  const { admin } = useAuth();
  const [users, setUsers] = useState([]);
  const [activeUser, setActiveUser] = useState(null);
  const [messages, setMessages] = useState([]);
  const [inputMsg, setInputMsg] = useState("");
  const [isTyping, setIsTyping] = useState(false);

  const messagesEndRef = useRef(null);
  const typingTimerRef = useRef(null);      // clears peer typing after timeout
  const mountedRef = useRef(false);

  const scrollToBottom = () =>
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });

  useEffect(scrollToBottom, [messages]);

  // Join admin room
  useEffect(() => {
    mountedRef.current = true;
    if (admin?._id) socket.emit("join", admin._id);

    return () => {
      mountedRef.current = false;
      socket.emit("stopTyping", { senderId: admin?._id, receiverId: activeUser?._id });
      socket.off("receiveMessage");
      socket.off("typing");
      socket.off("stopTyping");
    };
  }, [admin?._id]);

  // Fetch all customers
  useEffect(() => {
    if (!admin?.token) return;
    fetch(`${API_BASE_URL}/api/admin/customers`, {
      headers: { Authorization: `Bearer ${admin.token}` },
    })
      .then((r) => r.json())
      .then((d) => Array.isArray(d) && setUsers(d))
      .catch(() => setUsers([]));
  }, [admin?.token]);

  // Select user → fetch chat + mark read
  const selectUser = async (user) => {
    setActiveUser(user);
    const r = await fetch(`${API_BASE_URL}/api/chat/${user._id}`, {
      headers: { Authorization: `Bearer ${admin.token}` },
    });
    const data = await r.json();
    setMessages(data);
    await fetch(`${API_BASE_URL}/api/chat/read/${user._id}`, {
      method: "PUT",
      headers: { Authorization: `Bearer ${admin.token}` },
    });
  };

  const sendMessage = () => {
    if (!inputMsg.trim() || !activeUser) return;

    socket.emit("sendMessage", {
      senderId: admin._id,
      receiverId: activeUser._id,
      message: inputMsg.trim(),
    });

    // optimistic echo (server will also echo with _id/status later)
    setMessages((prev) => [
      ...prev,
      {
        sender: admin._id,
        receiver: activeUser._id,
        message: inputMsg.trim(),
        status: "sent",
        isRead: false,
      },
    ]);

    setInputMsg("");
    socket.emit("stopTyping", { senderId: admin._id, receiverId: activeUser._id });
  };

  // Socket listeners (bind once, react to activeUser via state checks)
  useEffect(() => {
    const onReceive = (msg) => {
      if (!mountedRef.current) return;

      // Only append messages of the active conversation
      const isForThisChat =
        activeUser &&
        (msg.sender === activeUser._id ||
          msg.sender?._id === activeUser._id ||
          msg.receiver === activeUser._id ||
          msg.receiver?._id === activeUser._id);
      if (isForThisChat) setMessages((p) => [...p, msg]);
    };

    const onTyping = () => {
      if (!mountedRef.current) return;
      setIsTyping(true);

      // Auto-clear after 4s unless another typing arrives
      if (typingTimerRef.current) clearTimeout(typingTimerRef.current);
      typingTimerRef.current = setTimeout(() => {
        setIsTyping(false);
      }, 4000);
    };

    const onStopTyping = () => {
      if (!mountedRef.current) return;
      setIsTyping(false);
      if (typingTimerRef.current) {
        clearTimeout(typingTimerRef.current);
        typingTimerRef.current = null;
      }
    };

    socket.on("receiveMessage", onReceive);
    socket.on("typing", onTyping);
    socket.on("stopTyping", onStopTyping);

    return () => {
      socket.off("receiveMessage", onReceive);
      socket.off("typing", onTyping);
      socket.off("stopTyping", onStopTyping);
    };
  }, [activeUser?._id]);

  // stopTyping on blur / page hide
  useEffect(() => {
    const handleBlur = () => {
      if (admin?._id && activeUser?._id) {
        socket.emit("stopTyping", { senderId: admin._id, receiverId: activeUser._id });
      }
    };
    window.addEventListener("blur", handleBlur);
    document.addEventListener("visibilitychange", handleBlur);
    return () => {
      window.removeEventListener("blur", handleBlur);
      document.removeEventListener("visibilitychange", handleBlur);
    };
  }, [admin?._id, activeUser?._id]);

  return (
    <div className="flex h-[80vh] bg-white rounded-xl shadow overflow-hidden">

      {/* User List */}
      <div className="w-1/3 border-r p-4 overflow-y-auto">
        <h2 className="text-xl font-bold mb-4">Customers</h2>
        {users.map((u) => (
          <div
            key={u._id}
            onClick={() => selectUser(u)}
            className={`p-3 cursor-pointer rounded-lg mb-2 ${
              activeUser?._id === u._id ? "bg-gray-900 text-white" : "hover:bg-gray-100"
            }`}
          >
            <p className="font-semibold">{u.name}</p>
            <p className={`text-sm ${activeUser?._id === u._id ? "text-gray-300" : "text-gray-500"}`}>
              {u.email}
            </p>
          </div>
        ))}
      </div>

      {/* Chat Box */}
      <div className="w-2/3 flex flex-col">
        {activeUser ? (
          <>
            <div className="p-4 border-b font-semibold flex justify-between items-center">
              <span>Chat with: {activeUser.name}</span>
              {isTyping && (
                <span className="text-xs px-2 py-1 rounded bg-gray-100 text-gray-700">
                  typing…
                </span>
              )}
            </div>

            <div className="flex-1 p-4 overflow-y-auto space-y-2 bg-gray-50">
              {messages.map((msg, i) => {
                const isMine = msg.sender === admin._id || msg.sender?._id === admin._id;
                const status = msg.status || (msg.isRead ? "seen" : "sent");
                return (
                  <div
                    key={i}
                    className={`max-w-[70%] p-3 rounded-2xl text-sm shadow ${
                      isMine
                        ? "ml-auto bg-black text-white"
                        : "mr-auto bg-white text-black border"
                    }`}
                  >
                    <div>{msg.message}</div>
                    {isMine && (
                      <div className="text-[11px] mt-1 text-right opacity-90">
                        {status === "seen"
                          ? "✅✅ Seen"
                          : status === "delivered"
                          ? "✅✅ Delivered"
                          : "✅ Sent"}
                      </div>
                    )}
                  </div>
                );
              })}
              <div ref={messagesEndRef} />
            </div>

            <div className="p-3 border-t flex gap-2 bg-white">
              <input
                className="flex-1 border rounded-lg px-3 py-2 focus:outline-none focus:ring focus:ring-gray-200"
                placeholder="Type a message..."
                value={inputMsg}
                onChange={(e) => {
                  setInputMsg(e.target.value);
                  if (activeUser)
                    socket.emit("typing", { senderId: admin._id, receiverId: activeUser._id });
                }}
                onBlur={() => {
                  if (activeUser)
                    socket.emit("stopTyping", { senderId: admin._id, receiverId: activeUser._id });
                }}
              />
              <button
                onClick={sendMessage}
                className="bg-black text-white px-4 rounded-lg"
              >
                Send
              </button>
            </div>
          </>
        ) : (
          <div className="flex items-center justify-center flex-1 text-gray-500">
            Select a user to start chatting
          </div>
        )}
      </div>
    </div>
  );
}
