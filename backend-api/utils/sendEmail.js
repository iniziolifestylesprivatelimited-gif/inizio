import nodemailer from "nodemailer";

export const sendEmail = async (to, subject, html, attachments = []) => {
  try {
    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 465,
      secure: true,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    await transporter.sendMail({
      from: `"Whatnot Store" <${process.env.EMAIL_USER}>`,
      to,
      subject,
      html,
      attachments, // ✅ now it exists
    });

    console.log(`📧 Email sent to ${to}`);
  } catch (error) {
    console.error("Email sending failed:", error);
    throw new Error("Email failed");
  }
};
