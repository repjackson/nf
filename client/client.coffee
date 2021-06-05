@picked_sections = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_ingredients = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0


Template.home.onCreated ->
    @autorun => @subscribe 'order_count'
    @autorun => @subscribe 'product_count'
    @autorun => @subscribe 'ingredient_count'
    @autorun => @subscribe 'subscription_count'
    @autorun => @subscribe 'source_count'
Template.home.helpers
    order_count:-> Counts.get('order_count')
    product_count:-> Counts.get('product_count')
    ingredient_count:-> Counts.get('ingredient_count')
    subscription_count:-> Counts.get('subscription_count')
    source_countt:-> Counts.get('source_count')
        
        
        
Template.not_found.events
    'click .browser_back': ->
          window.history.back();



$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.body.events
    # 'click .button': ->
    #     $(e.currentTarget).closest('.button').transition('bounce', 1000)

    # 'click a(not:': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.healthclub.events
    # 'click .button': ->
    #     $('.global_container')
    #     .transition('fade out', 5000)
    #     .transition('fade in', 5000)


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
