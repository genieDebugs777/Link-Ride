package za.co.linkride.link_ride_api.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${linkride.mail.from}")
    private String fromAddress;

    @Value("${linkride.mail.from-name:Link Ride}")
    private String fromName;

    public EmailService(
            JavaMailSender mailSender) {

        this.mailSender = mailSender;
    }

    public void sendVerificationCode(
            String recipientEmail,
            String firstName,
            String verificationCode) {

        String subject =
                "Verify your Link Ride account";

        String body = """
                <div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#1f2937;">
                    <h2 style="color:#003F73;">Welcome to Link Ride</h2>

                    <p>Hi %s,</p>

                    <p>
                        Thank you for creating your Link Ride account.
                        Use the verification code below to confirm your email address:
                    </p>

                    <div style="
                        font-size:28px;
                        font-weight:700;
                        letter-spacing:8px;
                        padding:18px;
                        margin:24px 0;
                        text-align:center;
                        background:#f1f5f9;
                        border-radius:12px;
                        color:#003F73;">
                        %s
                    </div>

                    <p>
                        This verification code will expire shortly.
                        If you did not create a Link Ride account,
                        you can ignore this email.
                    </p>

                    <p>Link Ride</p>
                </div>
                """.formatted(
                escapeHtml(firstName),
                escapeHtml(verificationCode)
        );

        sendHtmlEmail(
                recipientEmail,
                subject,
                body
        );
    }

    public void sendPasswordResetCode(
            String recipientEmail,
            String firstName,
            String resetCode) {

        String subject =
                "Reset your Link Ride password";

        String body = """
                <div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#1f2937;">
                    <h2 style="color:#003F73;">Reset your password</h2>

                    <p>Hi %s,</p>

                    <p>
                        We received a request to reset the password
                        associated with your Link Ride account.
                    </p>

                    <p>Enter this one-time code in Link Ride:</p>

                    <div style="
                        font-size:28px;
                        font-weight:700;
                        letter-spacing:8px;
                        padding:18px;
                        margin:24px 0;
                        text-align:center;
                        background:#f1f5f9;
                        border-radius:12px;
                        color:#003F73;">
                        %s
                    </div>

                    <p>
                        This code expires in 15 minutes and can only be used once.
                    </p>

                    <p>
                        If you did not request a password reset,
                        you can safely ignore this email.
                    </p>

                    <p>Link Ride</p>
                </div>
                """.formatted(
                escapeHtml(firstName),
                escapeHtml(resetCode)
        );

        sendHtmlEmail(
                recipientEmail,
                subject,
                body
        );
    }

    public void sendWelcomeEmail(
            String recipientEmail,
            String firstName) {

        String subject =
                "Welcome to Link Ride";

        String body = """
                <div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#1f2937;">
                    <h2 style="color:#003F73;">You're ready to ride</h2>

                    <p>Hi %s,</p>

                    <p>
                        Your Link Ride email address has been verified
                        and your account is now active.
                    </p>

                    <p>
                        You can now sign in, plan journeys,
                        compare transport options and manage your trips.
                    </p>

                    <p>
                        Welcome to Link Ride.
                    </p>

                    <p>Link Ride</p>
                </div>
                """.formatted(
                escapeHtml(firstName)
        );

        sendHtmlEmail(
                recipientEmail,
                subject,
                body
        );
    }

    public void sendPasswordChangedEmail(
            String recipientEmail,
            String firstName) {

        String subject =
                "Your Link Ride password was changed";

        String body = """
                <div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#1f2937;">
                    <h2 style="color:#003F73;">Password changed</h2>

                    <p>Hi %s,</p>

                    <p>
                        The password for your Link Ride account
                        was changed successfully.
                    </p>

                    <p>
                        If you made this change, no further action is required.
                    </p>

                    <p>
                        If you did not make this change,
                        please reset your password immediately.
                    </p>

                    <p>Link Ride</p>
                </div>
                """.formatted(
                escapeHtml(firstName)
        );

        sendHtmlEmail(
                recipientEmail,
                subject,
                body
        );
    }

    private void sendHtmlEmail(
            String recipientEmail,
            String subject,
            String htmlBody) {

        try {
            MimeMessage message =
                    mailSender.createMimeMessage();

            MimeMessageHelper helper =
                    new MimeMessageHelper(
                            message,
                            "UTF-8"
                    );

            helper.setFrom(
                    fromAddress,
                    fromName
            );

            helper.setTo(
                    recipientEmail
            );

            helper.setSubject(
                    subject
            );

            helper.setText(
                    htmlBody,
                    true
            );

            mailSender.send(
                    message
            );

        } catch (MessagingException |
                 UnsupportedEncodingException |
                 MailException error) {

            throw new IllegalStateException(
                    "Unable to send Link Ride email.",
                    error
            );
        }
    }

    private String escapeHtml(
            String value) {

        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}