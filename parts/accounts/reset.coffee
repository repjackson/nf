if Meteor.isClient
    Template.reset_password.onCreated ->
        if Accounts._resetPasswordToken
            # var resetPassword = Router.current().params.token;
            Session.set 'resetPassword', Accounts._resetPasswordToken


    Template.reset_password.helpers
        resetPassword: ->
            resetPassword = Router.current().params.token
            resetPassword
            # return Session.get('resetPassword');


    Template.reset_password.events
        'submit #reset_password_form': (e, t) ->
            e.preventDefault()
            resetPassword = Router.current().params.token
            reset_password_form = $(e.currentTarget)
            password = reset_password_form.find('.password1').val()
            password_confirm = reset_password_form.find('.password2').val()
            #Check password is at least 6 chars long

            is_valid_password = (password, password_confirm) ->
                if password == password_confirm
                    if password.length >= 6 then true else false
                else
                    alert "passwords dont match"

            if is_valid_password(password, password_confirm)
                # if (isNotEmpty(password) && areValidPasswords(password, password_confirm)) {
                Accounts.resetPassword resetPassword, password, (err) ->
                    if err
                        console.error 'error'
                    else
                        Session.set 'resetPassword', null
                        Router.go '/'
            else
                alert 'passwords need to be at least 6 characters long'

    Template.forgot_password.onCreated ->
        @autorun -> Meteor.subscribe 'all_users'

    Template.forgot_password.events
        'click .submit_email': (e, t) ->
            e.preventDefault()
            emailVar = $('.email').val()

            trimInput = (val) -> val.replace /^\s*|\s*$/g, ''

            email_trim = trimInput(emailVar)
            email = email_trim.toLowerCase()
            Accounts.forgotPassword { email: email }, (err) ->
                if err
                    if err.message == 'user not found [403]'
                        alert 'email does not exist'
                    else
                        alert "error: #{err.message}"
                else
                    alert 'email sent'


        'click .submit_username': (e, t) ->
            e.preventDefault()
            username = $('.username').val().trim()
            console.log 'submitting username', username
            user = Meteor.users.findOne username:username
            email = user.emails[0].address
            if not email
                alert "no email found for user.  email admin@dao.af."

            Accounts.forgotPassword { email: email }, (err) ->
                if err
                    if err.message == 'user not found [403]'
                        alert 'email does not exist'
                    else
                        alert "error: #{err.message}"
                else
                    alert 'email sent'
