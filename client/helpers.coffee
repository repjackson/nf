Template.registerHelper 'from_now', (input)-> moment(input).fromNow()
Template.registerHelper 'cal_time', (input)-> moment(input).calendar()

Template.registerHelper 'parent', () -> Template.parentData()
Template.registerHelper 'parent_doc', () ->
    Docs.findOne @parent_id
    # Template.parentData()

Template.registerHelper 'model_docs_helper', (model) ->
    console.log model
    Docs.find 
        model:model
Template.registerHelper 'subs_ready', () -> 
    Template.instance().subscriptionsReady()

Template.registerHelper 'order_things',-> 
    Docs.find 
        model:'thing'
        order_id:@_id

Template.registerHelper 'order_count',-> Counts.get('order_count')
Template.registerHelper 'product_count',-> Counts.get('product_count')
Template.registerHelper 'ingredient_count',-> Counts.get('ingredient_count')
Template.registerHelper 'subscription_count',-> Counts.get('subscription_count')
Template.registerHelper 'source_count',-> Counts.get('source_count')
Template.registerHelper 'giftcard_count',-> Counts.get('giftcard_count')
Template.registerHelper 'user_count',-> Counts.get('user_count')
Template.registerHelper 'staff_count',-> Counts.get('staff_count')
Template.registerHelper 'customer_count',-> Counts.get('customer_count')


Template.registerHelper 'cart_subtotal', () -> 
    store_session_document = 
        Docs.findOne 
            model:'store_session'
    if store_session_document.cart_product_ids
        subtotal = 0
        for product in Docs.find(_id:$in:store_session_document.cart_product_ids).fetch()
            if product.price_usd
                subtotal += product.price_usd
                # console.log 'product', product
        subtotal
    
# Template.registerHelper 'my_cart_subtotal', () ->
    
#     subtotal = 0
#     for item in Docs.find(model:'thing',_author_id:Meteor.userId(),status:'cart').fetch()
#         # product = Docs.findOne(item.product_id)
#         # console.log product
#         subtotal += item.product_price
#         # if product
#         #     if product.price_usd
#         # if product.price_usd
#         #     console.log product.price_usd
#             # console.log 'product', product
#     # console.log subtotal
#     subtotal.toFixed(2)
    
    
    
Template.registerHelper 'product_sort_icon', () -> Session.get('product_sort_icon')
Template.registerHelper 'active_path', (metric) ->
    false

Template.registerHelper 'cart_product_docs', ()->
    if @cart_product_ids
        Docs.find
            model:'product'
            _id:$in:@cart_product_ids

Template.registerHelper 'user_from_id', (id)->
    Meteor.users.findOne id
Template.registerHelper 'kve', (key,value)-> @["#{key}"] is value
Template.registerHelper 'skv_is', (key,value)-> Session.equals(key,value)

Template.registerHelper 'lower', (input) ->
    input.toLowerCase()

Template.registerHelper 'gs', () ->
    Docs.findOne
        model:'global_settings'
Template.registerHelper 'display_mode', () -> Session.get('display_mode',true)
Template.registerHelper 'is_loading', () -> Session.get 'loading'
Template.registerHelper 'dev', () -> Meteor.isDevelopment
# Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
# Template.registerHelper 'is_handler', ()-> @handler_username is Meteor.user().username
# Template.registerHelper 'is_owner', ()-> @owner_username is Meteor.user().username
Template.registerHelper 'is_grandparent_author', () ->
    grandparent = Template.parentData(2)
    grandparent._author_id is Meteor.userId()
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'fixed', (input) ->
    if input
        input.toFixed(2)
Template.registerHelper 'int', (input) -> 
    if input
        input.toFixed(0)
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
Template.registerHelper 'last_initial', (user) ->
    @last_name[0]+'.'
Template.registerHelper 'first_letter', (user) ->
    @first_name[..0]+'.'
Template.registerHelper 'first_initial', (user) ->
    @first_name[..2]+'.'
    # moment(input).fromNow()
# Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
# Template.registerHelper 'upvote_class', () ->
#     if Meteor.userId()
#         if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
#     else ''
# Template.registerHelper 'downvote_class', () ->
#     if Meteor.userId()
#         if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'
#     else ''

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'

Template.registerHelper 'hsd', () ->
    Docs.findOne
        model:'home_stats'


# Template.registerHelper 'grabber', () ->
#     Meteor.users.findOne
        _id:@grabber_id



# Template.registerHelper 'is_grabber', () ->
#     @grabber_id is Meteor.userId()

Template.registerHelper 'total_potential_revenue', () ->
    @price_per_serving * @servings_amount

# Template.registerHelper 'servings_available', () ->
#     @price_per_serving * @servings_amount

Template.registerHelper 'session_is', (key, value)->
    Session.equals(key, value)

Template.registerHelper 'key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value

Template.registerHelper 'is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    key is value

Template.registerHelper 'parent_key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value



# Template.registerHelper 'in_role', (role)->
#     if Meteor.userId() and Meteor.user().roles 
#       role in Meteor.user().roles 
       

# Template.registerHelper 'parent_template', () -> Template.parentData()
    # Session.get 'displaying_profile'

# Template.registerHelper 'checking_in_doc', () ->
#     Docs.findOne
#         model:'healthclub_session'
#         current:true
#      # Session.get('session_document')

# Template.registerHelper 'current_session_doc', () ->
#         Docs.findOne
#             model:'healthclub_session'
#             current:true



# Template.registerHelper 'checkin_guest_docs', () ->
#     Docs.findOne Router.current().params.doc_id
#     session_document = Docs.findOne Router.current().params.doc_id
#     # console.log session_document.guest_ids
#     Docs.find
#         _id:$in:session_document.guest_ids


Template.registerHelper '_author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'is_text', () ->
    # console.log @field_type
    @field_type is 'text'

Template.registerHelper 'template_parent', () ->
    # console.log Template.parentData()
    Template.parentData()

Template.registerHelper 'fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        match = {}
        # if Meteor.user()
        #     match.view_roles = $in:Meteor.user().roles
        match.model = 'field'
        match.parent_id = model._id
        # console.log model
        cur = Docs.find match,
            sort:rank:1
        # console.log cur.fetch()
        cur

Template.registerHelper 'edit_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            # edit_roles:$in:Meteor.user().roles
        }, sort:rank:1

Template.registerHelper 'sortable_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            sortable:true
        }, sort:rank:1

# Template.registerHelper 'current_user', (input) ->
#     Meteor.user() and Meteor.user().username is Router.current().params.username



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'current_model', (input) ->
    Docs.findOne
        model:'model'
        slug: Router.current().params.model_slug

Template.registerHelper 'in_list', (key) ->
    if Meteor.userId()
        if Meteor.userId() in @["#{key}"] then true else false



Template.registerHelper 'product_orders', () ->
    Docs.find {
        model:'order'
        product_id:@_id
    }, 
        sort:_timestamp:-1
Template.registerHelper 'product_subs', () ->
    Docs.find {
        model:'sub'
        product_id:@_id
    }, 
        sort:_timestamp:-1
# Template.registerHelper 'is_current_staff', () ->
#     if Meteor.user() and Meteor.user().roles
#         # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
#         if 'staff' in Meteor.user().current_roles then true else false
# Template.registerHelper 'is_staff', () ->
#     if Meteor.user() and Meteor.user().roles
#         # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
#         if 'staff' in Meteor.user().roles then true else false



# Template.registerHelper 'is_owner', () ->
#     if Meteor.user() and Meteor.user().roles
#         # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
#         if 'owner' in Meteor.user().roles then true else false
# Template.registerHelper 'is_current_owner', () ->
#     if Meteor.user() and Meteor.user().roles
#         # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
#         if 'owner' in Meteor.user().current_roles then true else false

# Template.registerHelper 'is_frontdesk', () ->
#     if Meteor.user() and Meteor.user().roles
#         # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
#         if 'frontdesk' in Meteor.user().roles then true else false
# Template.registerHelper 'is_current_frontdesk', () ->
#     if Meteor.user() and Meteor.user().roles
#         # if _.intersection(['dev','staff'], Meteor.user().roles) then true else false
#         if 'frontdesk' in Meteor.user().current_roles then true else false


# Template.registerHelper 'is_dev', () ->
#     if Meteor.user() and Meteor.user().roles
#         if 'dev' in Meteor.user().roles then true else false

# Template.registerHelper 'is_eric', () -> if Meteor.userId() and Meteor.userId() in ['ytjpFxiwnWaJELZEd','rDqxdcTBTszjeMh9T'] then true else false

Template.registerHelper 'current_user', () ->  Meteor.users.findOne username:Router.current().params.username
Template.registerHelper 'is_current_user', () ->
    if Meteor.user()
        if Meteor.user().username is Router.current().params.username
            true
        else
            if Meteor.user().roles and 'dev' in Meteor.user().roles
                true
            else
                false
    else 
        false
# Template.registerHelper 'view_template', -> "#{@field_type_slug}_view"
# Template.registerHelper 'edit_template', -> "#{@field_type_slug}_edit"
# Template.registerHelper 'is_model', -> @model is 'model'

Template.registerHelper 'order_product', ->
    Docs.findOne 
        model:'product'
        _id:@product_id
Template.registerHelper 'sub_product', ->
    Docs.findOne 
        model:'product'
        _id:@product_id
# Template.body.events
#     'click .toggle_leftbar': -> $('.ui.sidebar').sidebar('toggle')

Template.registerHelper 'is_editing', () -> Session.equals 'editing_id', @_id
Template.registerHelper 'editing_doc', () ->
    Docs.findOne Session.get('editing_id')

# Template.registerHelper 'can_edit', () ->
#     if Meteor.user()
#         Meteor.userId() is @_author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
Template.registerHelper 'ingredient_products', () -> 
    Docs.find 
        model:'product'
        ingredient_ids:$in:[@_id]
        


Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    # user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    # if doc then doc else if user then user
    if doc then doc


Template.registerHelper 'user_from_username_param', () ->
    found = Meteor.users.findOne username:Router.current().params.username
    # console.log found
    if found
        found
    else 
        Meteor.user()
Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    if parent
        parent["#{@key}"]


Template.registerHelper 'sorted_field_values', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        _.sortBy parent["#{@key}"], 'number'


# Template.registerHelper 'is_marketplace', () -> @model is 'marketplace'
# Template.registerHelper 'is_post', () -> @model is 'post'
# Template.registerHelper 'is_food', () -> @model is 'food'


Template.registerHelper 'in_dev', () -> Meteor.isDevelopment

Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'



Template.registerHelper 'in_dev', () -> Meteor.isDevelopment


# Template.registerHelper 'building_leader', () ->
#     Meteor.users.findOne @leader_id


# Template.registerHelper 'building_users', () ->
#     Meteor.users.find
#         _id: $in: @building_user_ids


# Template.registerHelper 'delta_key_value_is', (key, value)->
#     # console.log 'key', key
#     # console.log 'value', value
#     # console.log 'this', this
#     delta = Docs.findOne model:'delta'
#     delta["#{key}"] is value
