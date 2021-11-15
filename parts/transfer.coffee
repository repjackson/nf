# if Meteor.isClient
#     Template.registerHelper 'transfer_products', () -> 
#         Docs.find
#             model:'product'
#             transfer_id:@_id
#     Template.registerHelper 'product_transfer', () -> 
#         found = 
#             Docs.findOne
#                 model:'transfer'
#                 _id:@transfer_id
#         # console.log found
#         found
    
#     Router.route '/transfers', (->
#         @layout 'layout'
#         @render 'transfers'
#         ), name:'transfers'
#     Router.route '/transfer/:doc_id', (->
#         @layout 'layout'
#         @render 'transfer_view'
#         ), name:'transfer_view'
    
#     Template.transfers.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'transfer', 20, ->
            
            
            
#     Template.transfer_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#     Template.transfer_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'transfer_products', Router.current().params.doc_id
    

#     Template.transfer_view.helpers
#         transfer_products:->
#             Docs.find
#                 model:'product'
#                 transfer_id:@_id

#     Template.transfer_view.events
#         'click .add_transfer_product': ->
#             new_id = 
#                 Docs.insert 
#                     model:'product'
#                     transfer_id: Router.current().params.doc_id
#             Router.go "/product/#{new_id}/edit"        
            
#     Template.transfers.events
#         'click .add_transfer': ->
#             new_id = 
#                 Docs.insert 
#                     model:'transfer'
            
#             Router.go "/transfer/#{new_id}/edit"
            
        
# if Meteor.isServer
#     Meteor.publish 'transfer_products', (transfer_id)->
#         Docs.find   
#             model:'product'
#             transfer_id:transfer_id
            
            
# if Meteor.isClient
#     Router.route '/transfer/:doc_id/edit', (->
#         @layout 'layout'
#         @render 'transfer_edit'
#         ), name:'transfer_edit'



#     Template.transfer_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'username_search', Session.get('username_query'), ->


#     Template.user_picker.helpers
#         unpicked_users: ->
#             current_transfer = Docs.findOne Router.current().params.doc_id
#             Meteor.users.find 
#                 _id:$ne:current_transfer.target_user_id
#         picked_user: ->
#             current_transfer = Docs.findOne Router.current().params.doc_id
#             Meteor.users.findOne 
#                 _id:current_transfer.target_user_id
                
#     Template.user_picker.events
#         'click .pick_user': ->
#             Docs.update Router.current().params.doc_id,
#                 $set:target_user_id:@_id
#         'keyup .search_user': ->
#             val = $('.search_user').val()
#             Session.set('username_query',val)
        
#     Template.transfer_edit.events
#         'click .delete_transfer':->
#             if confirm 'delete?'
#                 Docs.remove @_id
#                 Router.go "/transfers"

            
#     Template.transfer_edit.helpers
#         all_shop: ->
#             Docs.find
#                 model:'transfer'
                
# if Meteor.isServer
#     Meteor.publish 'username_search', (query)->
#         console.log 'search', query
#         Meteor.users.find 
#             username:{$regex:query,$options:'i'}


if Meteor.isClient
    Router.route '/transfer/:doc_id/edit', (->
        @layout 'layout'
        @render 'transfer_edit'
        ), name:'transfer_edit'
        
        
    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_transfer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'tag_results',
            # Router.current().params.doc_id
            picked_tags.array()
            Session.get('searching')
            Session.get('current_query')
            Session.get('dummy')
        
    Template.transfer_edit.onRendered ->


    Template.transfer_edit.helpers
        terms: ->
            Terms.find()
        suggestions: ->
            Tags.find()
        recipient: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer.recipient_id
                Meteor.users.findOne
                    _id: transfer.recipient_id
        members: ->
            transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     transfer = Docs.findOne Router.current().params.doc_id
        #     transfer.amount*transfer.recipient_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            transfer = Docs.findOne Router.current().params.doc_id
            transfer.amount and transfer.recipient_id
    Template.transfer_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                picked_tags.push element_val
                Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 1000)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            picked_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # picked_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            picked_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            Session.set('dummy', !Session.get('dummy'))

    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    
        'blur .point_amount': (e,t)->
            # console.log @
            val = parseInt t.$('.point_amount').val()
            Docs.update Router.current().params.doc_id,
                $set:amount:val



        'click .cancel_transfer': ->
            Swal.fire({
                title: "confirm cancel?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'red'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go '/'
            )
            
        'click .submit': ->
            Swal.fire({
                title: "confirm send #{@amount}pts?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'green'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_transfer', @_id, =>
                        Swal.fire(
                            title:"#{@amount} sent"
                            icon:'success'
                            showConfirmButton: false
                            position: 'top-end',
                            timer: 1000
                        )
                        Router.go "/transfer/#{@_id}/view"
            )


    Template.transfer_edit.helpers
    Template.transfer_edit.events

if Meteor.isServer
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            recipient = Meteor.users.findOne transfer.recipient_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return
            
            
            
if Meteor.isClient
    Router.route '/transfers/', (->
        @layout 'layout'
        @render 'transfers'
        ), name:'transfers'
    

    Router.route '/transfer/:doc_id/view', (->
        @layout 'layout'
        @render 'transfer_view'
        ), name:'transfer_view'

    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.transfer_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find 
            _id:transfer.product_id            