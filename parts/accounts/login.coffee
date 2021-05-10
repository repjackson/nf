if Meteor.isClient
    Template.login.onCreated ->
        Session.set 'username', null

    Template.login.events
        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    console.log res
                    Session.set('enter_mode', 'login')

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set('enter_mode', 'login')

        'click .enter': (e,t)->
            e.preventDefault()
            username = $('.username').val()
            password = $('.password').val()
            options = {
                username:username
                password:password
                }
            # console.log options
            Meteor.loginWithPassword username, password, (err,res)=>
                if err
                    console.log err
                    $('body').toast({
                        message: err.reason
                    })
                else
                    # console.log res
                    Router.go "/"
                    # Router.go "/user/#{username}"

        'keyup .password, keyup .username': (e,t)->
            if e.which is 13
                e.preventDefault()
                username = $('.username').val()
                password = $('.password').val()
                if username and username.length > 0 and password and password.length > 0
                    options = {
                        username:username
                        password:password
                        }
                    # console.log options
                    Meteor.loginWithPassword username, password, (err,res)=>
                        if err
                            console.log err
                            $('body').toast({
                                message: err.reason
                            })
                        else
                            # Router.go "/user/#{username}"
                            Router.go "/"


    Template.login.helpers
        username: -> Session.get 'username'
        logging_in: -> Session.equals 'enter_mode', 'login'
        enter_class: ->
            if Session.get('username').length
                if Meteor.loggingIn() then 'loading disabled' else ''
            else
                'disabled'
        is_logging_in: -> Meteor.loggingIn()
