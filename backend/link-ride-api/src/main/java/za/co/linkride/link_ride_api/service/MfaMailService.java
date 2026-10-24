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
public class MfaMailService {

    private final JavaMailSender mailSender;

    @Value("${linkride.mail.from}")
    private String fromAddress;

    @Value("${linkride.mail.from-name:Link Ride}")
    private String fromName;

    public MfaMailService(
            JavaMailSender mailSender) {

        this.mailSender = mailSender;
    }

    public void sendMfaCode(
            String recipientEmail,
            String firstName,
            String code) {

        String subject =
                "Your Link Ride sign-in code";

        String body = """
                <div style="font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#1f2937;">
                    <h2 style="color:#003F73;">Confirm your sign-in</h2>

                    <p>Hi %s,</p>

                    <p>
                        Your Link Ride password was accepted.
                        Enter the one-time code below to finish signing in:
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
                        This code expires in 10 minutes.
                        If you did not try to sign in, you can ignore this email.
                    </p>

                    <p>Link Ride</p>
                </div>
                """.formatted(
                escapeHtml(firstName),
                escapeHtml(code)
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
                    "Unable to send Link Ride MFA email.",
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
