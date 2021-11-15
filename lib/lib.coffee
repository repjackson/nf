@Docs = new Meteor.Collection 'docs'
@Results = new Meteor.Collection 'results'

Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name
            "#{@first_name} #{@last_name}"
        else
            "#{@username}"
    shortname: ->
        if @nickname
            "#{@nickname}"
        else if @first_name
            "#{@first_name}"
        else
            "#{@username}"
    email_address: -> if @emails and @emails[0] then @emails[0].address
    email_verified: -> if @emails and @emails[0] then @emails[0].verified
    first_five_tags: ->
        if @tags
            @tags[..5]
    has_points: -> @points > 0
    # is_tech_admin: ->
    #     @_id in ['vwCi2GTJgvBJN5F6c','Dw2DfanyyteLytajt','LQEJBS6gHo3ibsJFu','YFPxjXCgjhMYEPADS','RWPa8zfANCJsczDcQ']


Docs.before.insert (userId, doc)->
    if Meteor.userId()
        doc._author_id = Meteor.userId()
        doc._author_username = Meteor.user().username
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    doc.app = 'nf'
    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return

if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


Docs.helpers
    # author: -> Meteor.users.findOne @_author_id
    # cook: -> Meteor.users.findOne @cook_user_id
    source_products: ->
        Docs.find
            model:'product'
            source_id:@_id
    when: -> moment(@_timestamp).fromNow()
    ten_tags: -> if @tags then @tags[..10]
    five_tags: -> if @tags then @tags[..4]
    three_tags: -> if @tags then @tags[..2]
    is_visible: -> @published in [0,1]
    # is_published: -> @published is 1
    # is_anonymous: -> @published is 0
    # is_private: -> @published is -1
    # from_user: ->
    #     if @from_user_id
    #         Meteor.users.findOne @from_user_id
    # to_user: ->
    #     if @to_user_id
    #         Meteor.users.findOne @to_user_id


    # order_total_transaction_amount: ->
    #     @serving_purchase_price+@cook_tip


    order: ->
        Docs.findOne
            model:'order'
            _id:@order_id
    product: ->
        Docs.findOne
            model:'product'
            _id:@product_id



    upvoters: ->
        if @upvoter_ids
            upvoters = []
            for upvoter_id in @upvoter_ids
                upvoter = Meteor.users.findOne upvoter_id
                upvoters.push upvoter
            upvoters
    downvoters: ->
        if @downvoter_ids
            downvoters = []
            for downvoter_id in @downvoter_ids
                downvoter = Meteor.users.findOne downvoter_id
                downvoters.push downvoter
            downvoters


Meteor.methods
    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:-1



