Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

Router.onBeforeAction(force_loggedin, {
  # only: ['admin']
  # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
  except: [
    'food'
    'register'
    'users'
    'services'
    'service_view'
    'products'
    'product_view'
    'rentals'
    'rental_view'
    'home'
    'forgot_password'
    'reset_password'
    'user_orders'
    'user_food'
    'user_finance'
    'user_dashboard'
    'verify-email'
    'food_view'
  ]
});


Router.route('enroll', {
    path: '/enroll-account/:token'
    template: 'reset_password'
    onBeforeAction: ()=>
        Meteor.logout()
        Session.set('_resetPasswordToken', this.params.token)
        @subscribe('enrolledUser', this.params.token).wait()
})


Router.route('verify-email', {
    path:'/verify-email/:token',
    onBeforeAction: ->
        console.log @
        # Session.set('_resetPasswordToken', this.params.token)
        # @subscribe('enrolledUser', this.params.token).wait()
        console.log @params
        Accounts.verifyEmail(@params.token, (err) =>
            if err
                console.log err
                alert err
                @next()
            else
                # alert 'email verified'
                # @next()
                Router.go "/verification_confirmation/"
        )
})


# Router.route '/m/:model_slug', (->
#     @render 'delta'
#     ), name:'delta'
# Router.route '/m/:model_slug/:doc_id/edit', -> @render 'model_doc_edit'
# Router.route '/m/:model_slug/:doc_id/view', (->
#     @render 'model_doc_view'
#     ), name:'doc_view'
# Router.route '/model/edit/:doc_id', -> @render 'model_edit'

# Router.route '/user/:username', -> @render 'user'
Router.route '/verification_confirmation', -> @render 'verification_confirmation'
Router.route '*', -> @render 'not_found'

# Router.route '/user/:username/m/:type', -> @render 'user_layout', 'user_section'
Router.route '/add_resident', (->
    @layout 'layout'
    @render 'add_resident'
    ), name:'add_resident'
Router.route '/forgot_password', -> @render 'forgot_password'

# Router.route "/food/:food_id", -> @render 'food_doc'

Router.route '/reset_password/:token', (->
    @render 'reset_password'
    ), name:'reset_password'

Router.route '/login', -> @render 'login'

# Router.route '/', -> @redirect '/m/model'
# Router.route '/', -> @redirect "/user/#{Meteor.user().username}"
