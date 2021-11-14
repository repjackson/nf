Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # if userId and doc._id == userId
        #     true


Docs.allow
    insert: (userId, doc) -> 
        true    
        # doc._author_id is userId
    update: (userId, doc) ->
        true
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> 
        true
        # doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.publish 'docs', (picked_tags, filter)->
    # user = Meteor.users.findOne @userId
    # console.log picked_tags
    # console.log filter
    self = @
    match = {}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
    #         match.view_roles = $in:Meteor.user().roles
    # else
    #     match.view_roles = $in:['public']

    # if filter is 'shop'
    #     match.active = true
    if picked_tags.length > 0 then match.tags = $all: picked_tags
    if filter then match.model = filter

    Docs.find match, sort:_timestamp:-1


# Meteor.users.allow
#     update: (userId, doc, fields, modifier) ->
#         true
#         # if userId and doc._id == userId
#         #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret



# SyncedCron.add
#     name: 'Update incident escalations'
#     schedule: (parser) ->
#         # parser is a later.parse object
#         parser.text 'every 1 hour'
#     job: ->
#         Meteor.call 'update_escalation_statuses', (err,res)->
#             # else


# SyncedCron.add({
#         name: 'check out members'
#         schedule: (parser) ->
#             parser.text 'every 2 hours'
#         job: ->
#             Meteor.call 'checkout_members', (err, res)->
#     },{
#         name: 'check leases'
#         schedule: (parser) ->
#             # parser is a later.parse object
#             parser.text 'every 24 hours'
#         job: ->
#             Meteor.call 'check_lease_status', (err, res)->
#     }
# )


# if Meteor.isProduction
#     SyncedCron.start()



Meteor.publish 'model_from_child_id', (child_id)->
    child = Docs.findOne child_id
    Docs.find
        model:'model'
        slug:child.type


Meteor.publish 'model_fields_from_child_id', (child_id)->
    child = Docs.findOne child_id
    model = Docs.findOne
        model:'model'
        slug:child.type
    Docs.find
        model:'field'
        parent_id:model._id

Meteor.publish 'all_users', ()->
    Meteor.users.find {},
        limit:20
    
    
Meteor.publish 'model_docs', (model,limit)->
    if limit
        Docs.find {
            model: model
            # app:'nf'
        }, 
            limit:limit
    else
        Docs.find {
            # app:'nf'
            model: model
        }, sort:_timestamp:-1
Meteor.publish 'me', ->
    Meteor.users.find({_id:@userId},{
        fields:
            username:1
            image_id:1
            tags:1
            points:1
    })

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug



Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find user_id

# Meteor.publish 'page', (slug)->
#     Docs.find
#         model:'page'
#         slug:slug


Meteor.publish 'doc_tags', (picked_tags)->

    user = Meteor.users.findOne @userId
    # current_herd = user.profile.current_herd

    self = @
    match = {}

    # picked_tags.push current_herd
    match.tags = $all: picked_tags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    cloud.forEach (tag, i) ->

        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()



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


