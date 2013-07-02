package org.telscenter.sail.webapp.presentation.web.controllers.forgotaccount;

import java.util.Date;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.sail.webapp.domain.User;
import net.sf.sail.webapp.domain.authentication.MutableUserDetails;
import net.sf.sail.webapp.mail.JavaMailHelper;
import net.sf.sail.webapp.service.UserService;

import org.apache.commons.lang.StringUtils;
import org.springframework.context.MessageSource;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.SimpleFormController;
import org.telscenter.sail.webapp.domain.impl.ReminderParameters;

public class ResetPasswordController extends SimpleFormController {

	protected UserService userService = null;
	private Properties portalProperties;
	protected JavaMailHelper javaMail = null;
	private MessageSource messageSource;
	
	/**
	 * Performs processing whenever the resetpassword.html form is shown.
	 * This handles displaying the form when the user is requested to
	 * enter a new password and also handles displaying the form when
	 * the user successfully changes their password.
	 * @see org.springframework.web.servlet.mvc.SimpleFormController#showForm(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse, org.springframework.validation.BindException)
	 */
	@Override
	protected ModelAndView showForm(HttpServletRequest request, HttpServletResponse response, BindException errors) throws Exception {
		ModelAndView modelAndView = super.showForm(request, response, errors);
		
		//get the reset password key
		String resetPasswordKey = request.getParameter("k");
		
		//boolean values that will be used in the jsp to determine what to display
		boolean displayForgotPasswordSelectAccountTypeLink = false;
		boolean displayLoginLink = false;
		boolean passwordResetSuccess = false;
		
		/*
		 * determine if we have successfully reset the password.
		 * this will only be true after they have submitted the
		 * password change form successfully and we call showForm()
		 * again.
		 */
		if(request.getAttribute("passwordResetSuccess") != null) {
			passwordResetSuccess = (Boolean) request.getAttribute("passwordResetSuccess");
		}
		
		if(passwordResetSuccess) {
			//we want to display the success page and display a link to login
			displayLoginLink = true;
		} else {
			//make sure we have a reset password key
			if(resetPasswordKey != null) {
				//get the user associated with this reset password key
				User user = userService.retrieveByResetPasswordKey(resetPasswordKey);
				
				if(user != null) {
					//get the time the reset password email was sent
					MutableUserDetails userDetails = user.getUserDetails();
					Date resetPasswordRequestTime = userDetails.getResetPasswordRequestTime();
					long resetPasswordRequestTimeMs = resetPasswordRequestTime.getTime();
					
					//get the current time
					Date now = new Date();
					long nowMs = now.getTime();
					
					/*
					 * check if the reset password request has expired because it was made 
					 * more than 30 minutes ago
					 * 1000 * 60 * 30 = 1800000
					 */
					if(nowMs - resetPasswordRequestTimeMs > 1800000) {
						//reset password link has expired 
						errors.reject("error.password-reset-timeout");
						
						//variable to tell the jsp page to display the link to the forgot password page
						displayForgotPasswordSelectAccountTypeLink = true;
					}
				} else {
					/*
					 * we could not find a user with the given reset password 
					 * key so this password reset url is invalid
					 */
					errors.reject("error.invalid-password-reset-url");
					
					//variable to tell the jsp page to display the link to the forgot password page
					displayForgotPasswordSelectAccountTypeLink = true;
				}
			} else {
				//there is no reset password key provided as a GET param so this password reset url is invalid
				errors.reject("error.invalid-password-reset-url");
				
				//variable to tell the jsp page to display the link to the forgot password page
				displayForgotPasswordSelectAccountTypeLink = true;
			}
		}
		
		Map model = modelAndView.getModel();
		model.put("displayForgotPasswordSelectAccountTypeLink", displayForgotPasswordSelectAccountTypeLink);
		model.put("displayLoginLink", displayLoginLink);
		
		return modelAndView;
	}
	
	/**
	 * Called when the user chooses a new password and submits the form.
	 * @see org.springframework.web.servlet.mvc.SimpleFormController#onSubmit(javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse, java.lang.Object, org.springframework.validation.BindException)
	 */
	@Override
	protected ModelAndView onSubmit(HttpServletRequest request,
			HttpServletResponse response, Object command, BindException errors)
			throws Exception {
		//get the object that can be referenced in the jsp
		ReminderParameters reminderParameters = (ReminderParameters) command;
		
		//get the password values the user entered
		String newPassword = reminderParameters.getNewPassword();
		String verifyPassword = reminderParameters.getVerifyPassword();

		//make the passwords lower case
		verifyPassword = StringUtils.lowerCase(verifyPassword);
		newPassword = StringUtils.lowerCase(newPassword);
		
		if (!verifyPassword.equals(newPassword)) {
			//passwords are not the same
			errors.reject("error.verify-newpassword");
			
			//show the form again, this time displaying the error message
			return showForm(request, response, errors);
		} else if(verifyPassword.equals("")) {
			//password is empty string
			errors.reject("error.verify-password-empty");
			
			//show the form again, this time displaying the error message
			return showForm(request, response, errors);
		} else {
			//get the reset password key
			String resetPasswordKey = request.getParameter("k");
			
			//get the user associated with the reset password key
			User user = userService.retrieveByResetPasswordKey(resetPasswordKey);
			
			//update the user's password
			userService.updateUserPassword(user, verifyPassword);
			
			//set the reset password key and time so the key can no longer be used
			user.getUserDetails().setResetPasswordKey(null);
			user.getUserDetails().setResetPasswordRequestTime(null);
			userService.updateUser(user);

			//get the user name
			String username = user.getUserDetails().getUsername();
			
			//get the portal name
			String portalName = portalProperties.getProperty("portal.name");
			
			//get the user's email
			String userEmail = user.getUserDetails().getEmailAddress();
			String[] recipients = new String[]{userEmail};
			
			// get user Locale
			Locale userLocale = request.getLocale();
			
			// subject looks like this: "Notification from WISE4@Berkeley: Password Changed"
			String defaultSubject = messageSource.getMessage("password.changed.email.subject", new Object[]{portalName}, Locale.US); 
			String subject = messageSource.getMessage("password.changed.email.subject", new Object[]{portalName}, defaultSubject, userLocale); 
			String defaultBody = messageSource.getMessage("password.changed.email.body", new Object[]{username,portalName}, Locale.US);
			String body = messageSource.getMessage("password.changed.email.body", new Object[] {username,portalName}, defaultBody, userLocale);				
			
			// send password in the email here
			javaMail.postMail(recipients, subject, body, userEmail);
			
			//passwords are the same so we will change their password
			errors.reject("error.password-reset-success");

			//tell the jsp to display the success message
			request.setAttribute("passwordResetSuccess", true);
			
			//show the form again, this time with the success message
			return showForm(request, response, errors);
		}
	}
	
	/**
	 * Sets the userDetailsService object.
	 * 
	 * @param userDetailsService
	 */
	public void setUserService(UserService userService) {
		this.userService = userService;
	}
	
	/**
	 * @param portalProperties the portalProperties to set
	 */
	public void setPortalProperties(Properties portalProperties) {
		this.portalProperties = portalProperties;
	}

	/**
	 * helper for sending emails
	 * 
	 * @param javaMail
	 */
	public void setJavaMail(JavaMailHelper javaMail) {
		this.javaMail = javaMail;
	}
	
	/**
	 * @param messageSource the messageSource to set
	 */
	public void setMessageSource(MessageSource messageSource) {
		this.messageSource = messageSource;
	}
}
