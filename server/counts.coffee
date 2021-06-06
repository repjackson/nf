Meteor.publish 'order_count', (
    )->
    @unblock()
    self = @
    match = {model:'order', app:'nf'}
    Counts.publish this, 'order_count', Docs.find(match)
    return undefined
Meteor.publish 'ingredient_count', (
    )->
    @unblock()
    self = @
    match = {model:'ingredient', app:'nf'}
    Counts.publish this, 'ingredient_count', Docs.find(match)
    return undefined
Meteor.publish 'product_count', (
    )->
    @unblock()
    self = @
    match = {model:'product', app:'nf'}
    Counts.publish this, 'product_count', Docs.find(match)
    return undefined
Meteor.publish 'source_count', (
    )->
    @unblock()
    self = @
    match = {model:'source', app:'nf'}
    Counts.publish this, 'source_count', Docs.find(match)
    return undefined
Meteor.publish 'subscription_count', (
    )->
    @unblock()
    self = @
    match = {model:'product_subscription', app:'nf'}
    Counts.publish this, 'subscription_count', Docs.find(match)
    return undefined
    
    
Meteor.publish 'giftcard_count', (
    )->
    @unblock()
    self = @
    match = {model:'giftcard', app:'nf'}
    Counts.publish this, 'giftcard_count', Docs.find(match)
    return undefined
