package za.co.linkride.link_ride_api.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;

@Service
@Profile("!prod")
public class SmtpHtmlEmailTransport implements HtmlEmailTransport {
    private final JavaMailSender mailSender;
    private final String fromAddress;
    private final String fromName;

    public SmtpHtmlEmailTransport(JavaMailSender mailSender,
                                  @Value("${linkride.mail.from}") String fromAddress,
                                  @Value("${linkride.mail.from-name:Link Ride}") String fromName) {
        this.mailSender = mailSender;
        this.fromAddress = fromAddress;
        this.fromName = fromName;
    }

    @Override
    public void send(String recipientEmail, String subject, String htmlBody) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, "UTF-8");
            helper.setFrom(fromAddress, fromName);
            helper.setTo(recipientEmail);
            helper.setSubject(subject);
            helper.setText(htmlBody, true);
            mailSender.send(message);
        } catch (MessagingException | UnsupportedEncodingException | MailException error) {
            throw new IllegalStateException("Unable to send Link Ride email via SMTP.", error);
        }
    }
}
