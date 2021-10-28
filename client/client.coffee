@picked_sections = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_ingredients = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0


# Template.home.onCreated ->
#     @autorun => @subscribe 'model_docs', 'stats', ->
# Template.home.onRendered ->
#     Meteor.call 'log_homepage_view', ->
#         console.log '?'
# Template.home.helpers
#     stats: ->
#         Docs.findOne
#             model:'stats'

# Template.nav.onCreated ->
#     @autorun => @subscribe 'order_count'
#     @autorun => @subscribe 'product_count'
#     @autorun => @subscribe 'ingredient_count'
#     @autorun => @subscribe 'subscription_count'
#     @autorun => @subscribe 'source_count'
#     @autorun => @subscribe 'giftcard_count'
#     @autorun => @subscribe 'user_count'
        
        
Template.not_found.events
    'click .browser_back': ->
          window.history.back();



$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.body.events
    'click .fly_right': (e,t)-> $(e.currentTarget).closest('.grid').transition('fly right', 500)
    # 'click .fly_right': (e,t)-> $(e.currentTarget).closest('.grid').transition('drop', 500)
    'click .fly_left': (e,t)-> $(e.currentTarget).closest('.grid').transition('fly left', 500)
    # 'click .button': ->
    #     $(e.currentTarget).closest('.button').transition('bounce', 1000)

    # 'click a(not:': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.healthclub.events
    # 'click .button': ->
    #     $('.global_container')
    #     .transition('fade out', 5000)
    #     .transition('fade in', 5000)


# Tracker.autorun ->
#     current = Router.current()
#     Tracker.afterFlush ->
#         $(window).scrollTop 0


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
