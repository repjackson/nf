@selected_rental_tags = new ReactiveArray []
@selected_tags = new ReactiveArray []
@selected_ingredients = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0



$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.body.events
    'click a': ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

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




# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
