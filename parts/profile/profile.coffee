if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/cart', (->
        @layout 'user_layout'
        @render 'cart'
        ), name:'user_cart'
    Router.route '/user/:username/credit', (->
        @layout 'user_layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/user/:username/orders', (->
        @layout 'user_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/friends', (->
        @layout 'user_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/subs', (->
        @layout 'user_layout'
        @render 'user_subs'
        ), name:'user_subs'
    Router.route '/user/:username/subscriptions', (->
        @layout 'user_layout'
        @render 'user_subs'
        ), name:'user_subscriptions'
    Router.route '/user/:username/addresses', (->
        @layout 'user_layout'
        @render 'user_addresses'
        ), name:'user_addresses'
    Router.route '/user/:username/deliveries', (->
        @layout 'user_layout'
        @render 'user_deliveries'
        ), name:'user_deliveries'
    Router.route '/user/:username/favorites', (->
        @layout 'user_layout'
        @render 'user_favorites'
        ), name:'user_favorites'
    Router.route '/user/:username/posts', (->
        @layout 'user_layout'
        @render 'user_posts'
        ), name:'user_posts'
    Router.route '/user/:username/pantry', (->
        @layout 'user_layout'
        @render 'user_pantry'
        ), name:'user_pantry'







    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.user_layout.helpers
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.user_layout.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
