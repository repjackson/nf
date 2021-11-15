Template.youtube_edit.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.youtube_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000


Template.youtube_edit.events
    'blur .youtube_id': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.youtube_id').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val



Template.color_edit.events
    'blur .edit_color': (e,t)->
        val = t.$('.edit_color').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val



Template.html_edit.onRendered ->
    @editor = SUNEDITOR.create((document.getElementById('sample') || 'sample'),{
        # codeMirror: CodeMirror
        buttonList: [
            [
                'undo' 
                'redo'
                'font' 
                'fontSize' 
                'formatBlock' 
                'paragraphStyle' 
                'blockquote'
                'bold' 
                'underline' 
                'italic' 
                'strike' 
                'subscript' 
                'superscript'
                'fontColor' 
                'hiliteColor' 
                'textStyle'
                'removeFormat'
                'outdent' 
                'indent'
                'align' 
                'horizontalRule' 
                'list' 
                'lineHeight'
                'fullScreen' 
                'showBlocks' 
                'codeView' 
                'preview' 
                'table' 
                'image' 
                'video' 
                'audio' 
                'link'
            ]
        ]
        
        lang: SUNEDITOR_LANG['en']
    });

Template.html_edit.events
    'blur .testsun': (e,t)->
        html = t.editor.getContents(onlyContents: Boolean);

        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":html
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":html


Template.html_edit.helpers
        


Template.color_icon_edit.events
    'blur .color_icon': (e,t)->
        val = t.$('.color_icon').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.clear_value.events
    'click .clear_value': ->
        if confirm "Clear #{@title} field?"
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1


Template.link_edit.events
    'blur .edit_url': (e,t)->
        val = t.$('.edit_url').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.icon_edit.events
    'blur .icon_val': (e,t)->
        val = t.$('.icon_val').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.image_edit.events
    "change input[name='upload_image']": (e) ->
        files = e.currentTarget.files
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                # console.dir res
                if err
                    console.error 'Error uploading', err
                else
                    doc = Docs.findOne parent._id
                    user = Meteor.users.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $set:"#{@key}":res.public_id
                    else if user
                        Meteor.users.update parent._id,
                            $set:"#{@key}":res.public_id


    'blur .cloudinary_id': (e,t)->
        cloudinary_id = t.$('.cloudinary_id').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        Docs.update parent._id,
            $set:"#{@key}":cloudinary_id


    'click #remove_photo': ->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        if confirm 'Remove Photo?'
            # Docs.update parent._id,
            #     $unset:"#{@key}":1
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1






Template.array_edit.events
    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim()
            if @direct
                parent = Template.parentData()
            else
                parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $addToSet:"#{@key}":element_val
            else if user
                Meteor.users.update parent._id,
                    $addToSet:"#{@key}":element_val
            t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        element = @valueOf()
        field = Template.currentData()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{field.key}":element
        else if user
            Meteor.users.update parent._id,
                $pull:"#{field.key}":element

        t.$('.new_element').focus()
        t.$('.new_element').val(element)


# Template.textarea.onCreated ->
#     @editing = new ReactiveVar false

# Template.textarea.helpers
#     is_editing: -> Template.instance().editing.get()


Template.textarea_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":textarea_val



Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.address_edit.events
    'blur .edit_address': (e,t)->
        val = t.$('.edit_address').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.slug_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


    'click .slugify_title': (e,t)->
        page_doc = Docs.findOne Router.current().params.doc_id
        # val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        Meteor.call 'slugify', page_doc._id, (err,res)=>
            Docs.update page_doc._id,
                $set:slug:res

Template.phone_edit.events
    'blur .edit_phone': (e,t)->
        val = t.$('.edit_phone').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.boolean_edit.helpers
    boolean_toggle_class: ->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        if parent["#{@key}"] then 'active' else 'basic'


Template.boolean_edit.events
    'click .toggle_boolean': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        # $(e.currentTarget).closest('.button').transition('pulse', 100)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]



Template.number_edit.events
    'blur .edit_number': (e,t)->
        # console.log @
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = parseInt t.$('.edit_number').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


Template.float_edit.events
    'blur .edit_float': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = parseFloat t.$('.edit_float').val()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val


# Template.dollar_price_view.onCreated ->
# 	# Session.set 'giveAmount', ''
#     if Meteor.isDevelopment
#         pub_key = Meteor.settings.public.stripe_test_publishable
#     else if Meteor.isProduction
#         pub_key = Meteor.settings.public.stripe_live_publishable
#     Template.instance().checkout = StripeCheckout.configure(
#         key: pub_key
#         image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
#         locale: 'auto'
#         # zipCode: true
#         token: (token) ->
#             product = Docs.findOne Router.current().params.doc_id
#             charge =
#                 amount: product.dollar_price*100
#                 currency: 'usd'
#                 source: token.id
#                 description: token.description
#                 # receipt_email: token.email
#             Meteor.call 'STRIPE_single_charge', charge, product, (error, response) =>
#                 if error then alert error.reason, 'danger'
#                 else
#                     alert 'Payment received.', 'success'
#                     Docs.insert
#                         model:'transaction'
#                         product_id:product._id
# 	)



Template.date_edit.events
    'blur .edit_date': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.edit_date').val()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.datetime_edit.events
    'blur .edit_datetime': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.edit_datetime').val()
        console.log val
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val





Template.time_edit.events
    'blur .edit_time': (e,t)->
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        val = t.$('.edit_time').val()

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else if user
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.children_view.onCreated ->
    # @autorun => Meteor.subscribe 'children', @data.ref_model, Template.parentData(5)._id
    @autorun => Meteor.subscribe 'child_docs', Template.parentData(5)._id
    @autorun => Meteor.subscribe 'model_from_slug', @data.ref_model
    @autorun => Meteor.subscribe 'model_fields_from_slug', @data.ref_model

Template.children_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.children_view.helpers
    children: ->
        field = @
        # if Template.parentData(5)
        # else
        parent = Template.parentData(5)
        Docs.find {
            model: @ref_model
            parent_id: parent._id
            # view_roles:$in:Meteor.user().roles
        }, sort:rank:1


Template.children_edit.onCreated ->
    @autorun => Meteor.subscribe 'children', @data.ref_model, Template.parentData(5)._id
    # @autorun => Meteor.subscribe 'child_docs', Template.parentData(5)._id
    @autorun => Meteor.subscribe 'model_from_slug', @data.ref_model
    @autorun => Meteor.subscribe 'model_fields', @data.ref_model
Template.children_view.onCreated ->
    @autorun => Meteor.subscribe 'children', @data.ref_model, Template.parentData(5)._id
    # @autorun => Meteor.subscribe 'child_docs', Template.parentData(5)._id
    @autorun => Meteor.subscribe 'model_from_slug', @data.ref_model
    @autorun => Meteor.subscribe 'model_fields', @data.ref_model

Template.children_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.child_edit.helpers
    child_fields: ->
        model = Docs.findOne
            model:'model'
            slug:@model
        Docs.find
            model:'field'
            parent_id:model._id

Template.child_view.helpers
    child_fields: ->
        model = Docs.findOne
            model:'model'
            slug:@model
        Docs.find
            model:'field'
            parent_id:model._id


Template.children_edit.helpers
    children: ->
        field = @

        # if Template.parentData(5)
        # else
        parent = Template.parentData(5)
        Docs.find {
            model: @ref_model
            parent_id: parent._id
            # view_roles:$in:Meteor.user().roles
        }, sort:rank:1


Template.children_edit.events
    'click .add_child': ->
        parent = Template.parentData()
        parent2 = Template.parentData(2)
        parent3 = Template.parentData(3)
        parent4 = Template.parentData(4)
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)


        new_id = Docs.insert
            model: @ref_model
            parent_id: parent5._id
            parent_model:Router.current().params.model_slug






Template.textarea_view.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000




Template.single_doc_view.onCreated ->
    # @autorun => Meteor.subscribe 'model_docs', @data.ref_model

Template.single_doc_view.helpers
    choices: ->
        Docs.find
            model:@ref_model




Template.single_doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', @data.ref_model

Template.single_doc_edit.helpers
    choices: ->
        if @ref_model
            Docs.find {
                model:@ref_model
            }, sort:slug:1
    calculated_label: ->
        ref_doc = Template.currentData()
        key = Template.parentData().button_label
        ref_doc["#{key}"]

    choice_class: ->
        selection = @
        current = Template.currentData()
        ref_field = Template.parentData(1)
        if ref_field.direct
            parent = Template.parentData(2)
        else
            parent = Template.parentData(5)
        target = Template.parentData(2)
        if @direct
            if target["#{ref_field.key}"]
                if @ref_field is target["#{ref_field.key}"] then 'active' else ''
            else ''
        else
            if parent["#{ref_field.key}"]
                if @slug is parent["#{ref_field.key}"] then 'active' else ''
            else ''


Template.single_doc_edit.events
    'click .select_choice': ->
        selection = @
        ref_field = Template.currentData()
        if ref_field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        # parent = Template.parentData(1)

        # key = ref_field.button_key
        key = ref_field.key


        # if parent["#{key}"] and @["#{ref_field.button_key}"] in parent["#{key}"]
        if parent["#{key}"] and @slug in parent["#{key}"]
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{ref_field.key}":1
            else if user
                Meteor.users.update parent._id,
                    $unset: "#{ref_field.key}":1
        else
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id

            if doc
                Docs.update parent._id,
                    $set: "#{ref_field.key}": @slug
            else if user
                Meteor.users.update parent._id,
                    $set: "#{ref_field.key}": @slug


Template.multi_doc_view.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', @data.ref_model

Template.multi_doc_view.helpers
    choices: ->
        Docs.find {
            model:@ref_model
        }, sort:number:-1

# Template.multi_doc_edit.onRendered ->
#     $('.ui.dropdown').dropdown(
#         clearable:true
#         action: 'activate'
#         onChange: (text,value,$selectedItem)->
#         )



Template.multi_doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', @data.ref_model
Template.multi_doc_edit.helpers
    choices: ->
        Docs.find model:@ref_model

    choice_class: ->
        selection = @
        current = Template.currentData()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        ref_field = Template.parentData(1)
        target = Template.parentData(2)

        if target["#{ref_field.key}"]
            if @slug in target["#{ref_field.key}"] then 'active' else ''
        else
            ''


Template.multi_doc_edit.events
    'click .select_choice': ->
        selection = @
        ref_field = Template.currentData()
        if ref_field.direct
            parent = Template.parentData(2)
        else
            parent = Template.parentData(6)
        parent = Template.parentData(1)
        parent2 = Template.parentData(2)
        parent3 = Template.parentData(3)
        parent4 = Template.parentData(4)
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
        parent7 = Template.parentData(7)

        #

        if parent["#{ref_field.key}"] and @slug in parent["#{ref_field.key}"]
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{ref_field.key}":@slug
            else if user
                Meteor.users.update parent._id,
                    $pull: "#{ref_field.key}": @slug
        else
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $addToSet: "#{ref_field.key}": @slug
            else if user
                Meteor.users.update parent._id,
                    $addToSet: "#{ref_field.key}": @slug


Template.single_user_edit.onCreated ->
    @user_results = new ReactiveVar
Template.single_user_edit.helpers
    user_results: ->Template.instance().user_results.get()
Template.single_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup #single_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#single_user_select_input').val().trim()
        if search_value.length > 1
            Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.doc_id
        field = Template.currentData()

        # console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)


        val = t.$('.edit_text').val()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{field.key}":@_id
        else
            Meteor.users.update parent._id,
                $set:"#{field.key}":@_id
            
        t.user_results.set null
        $('#single_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)
        # console.log Template.parentData(5)
        # console.log Template.parentData(6)
        # console.log Template.parentData(7)
        if confirm "remove #{@username}?"
            parent = Template.parentData(1)
            field = Template.currentData()
            Docs.update parent._id,
                $unset:"#{field.key}":1

        #     page_doc = Docs.findOne Router.current().params.doc_id
            # Meteor.call 'unassign_user', page_doc._id, @






Template.multi_user_edit.onCreated ->
    @user_results = new ReactiveVar
Template.multi_user_edit.helpers
    user_results: -> 
        Template.instance().user_results.get()
Template.multi_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null
    'keyup #multi_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#multi_user_select_input').val().trim()
        if e.which is 8
            t.user_results.set null
        else if search_value and search_value.length > 1
            Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                if err then console.error err
                else
                    # console.log res 
                    t.user_results.set res
    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.doc_id
        val = t.$('.edit_text').val()
        field = Template.currentData()

        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $addToSet:"#{field.key}":@_id
        else if user
            Meteor.users.update parent._id,
                $addToSet:"#{field.key}":@_id


        t.user_results.set null
        $('#multi_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        if confirm "remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{@key}":@_id
            else if user
                Meteor.users.update parent._id,
                    $pull:"#{@key}":@_id
            # Meteor.call 'unassign_user', page_doc._id, @



Template.multi_doc_input.onCreated ->
    # @autorun => Meteor.subscribe 'model_docs', 'guest'
    @doc_results = new ReactiveVar
Template.multi_doc_input.helpers
    doc_results: -> Template.instance().doc_results.get()
Template.multi_doc_input.events
    'click .clear_results': (e,t)->
        t.doc_results.set null
    'keyup #multi_doc_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('#multi_doc_select_input').val().trim()
        if search_value.length is 0
            t.doc_results.set null
        else if search_value
            Meteor.call 'lookup_doc', search_value, 'guest', (err,res)=>
                if err then console.error err
                else
                    # console.log res
                    t.doc_results.set res
    'click .select_doc': (e,t) ->
        # session_document = Docs.findOne Session.get('session_document')
        # if @direct
        #     parent = Template.parentData(1)
        # else
        #     parent = Template.parentData(5)
        parent = Docs.findOne _id: Router.current().params.doc_id
        Docs.update parent._id,
            $addToSet:guest_ids:@_id
        t.doc_results.set null
        $('#multi_user_select_input').val ''

    'click .pull_user': ->
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne Router.current().params.doc_id
            parent = Template.parentData(5)
            doc = Docs.findOne parent._id
            user = Meteor.users.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:"#{@key}":@_id
            else if user
                Meteor.users.update parent._id,
                    $pull:"#{@key}":@_id
            # Meteor.call 'unassign_user', page_doc._id, @





Template.range_edit.onRendered ->
    # item = Template.currentData()
    $('#rangestart').calendar({
        type: 'datetime'
        today: true
        # type:'time'
        inline: true
        endCalendar: $('#rangeend')
        formatter: {
            date: (date, settings)->
                if !date then return ''
                mst_date = moment(date)
                mst_date.format("YYYY-MM-DD[T]hh:mm")
        }
    });
    $('#rangeend').calendar({
        type: 'datetime'
        today: true
        # type:'time'
        inline: true
        startCalendar: $('#rangestart')
        formatter: {
            date: (date, settings)->
                if !date then return ''
                mst_date = moment(date)
                mst_date.format("YYYY-MM-DD[T]hh:mm")

        }
    })

Template.range_edit.events
    'click .get_start': ->
        doc_id = Router.current().params.doc_id
        result = $('.ui.calendar').calendar('get startDate')[1]
        formatted = moment(result).format("YYYY-MM-DD[T]HH:mm")
        # moment_ob = moment(result)
        Docs.update doc_id,
            $set:start_datetime:formatted


    'click .get_end': ->
        doc_id = Router.current().params.doc_id
        result = $('.ui.calendar').calendar('get endDate')[0]
        console.log result
        formatted = moment(result).format("YYYY-MM-DD[T]HH:mm")
        console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
        console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
        Docs.update doc_id,
            $set:end_datetime:formatted