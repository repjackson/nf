Meteor.publish 'order_count', (
    # picked_ingredients
    # picked_sections
    # post_query
    # view_vegan
    # view_gf
    )->
    # @unblock()

    # console.log picked_ingredients
    self = @
    match = {model:'order', app:'nf'}
    # if picked_ingredients.length > 0
    #     match.ingredients = $all: picked_ingredients
    #     # sort = 'price_per_serving'
    # if picked_sections.length > 0
    #     match.menu_section = $all: picked_sections
    #     # sort = 'price_per_serving'
    # # else
    #     # match.tags = $nin: ['wikipedia']
    # sort = '_timestamp'
        # match.source = $ne:'wikipedia'
    # if view_vegan
    #     match.vegan = true
    # if view_gf
    #     match.gluten_free = true
    # if post_query and post_query.length > 1
    #     console.log 'searching post_query', post_query
    #     match.title = {$regex:"#{post_query}", $options: 'i'}
    console.log Docs.find(match).fetch()
    Counts.publish this, 'order_count', Docs.find(match)
    return undefined
