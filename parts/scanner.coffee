{Html5QrcodeScanner} = require "html5-qrcode"
# generate = require "./qrcode.min.js"
# import "./qrcode.min.js"

{Html5Qrcode} = require "html5-qrcode"


# console.log "./qrcode.min.js"

if Meteor.isClient
    Router.route '/scanner', -> @render 'scanner'
    Router.route '/dashboard', -> @render 'scanner'

    Template.scanner.onCreated ->
        Session.setDefault('just_read',false)
    Template.scanner.onRendered ->
        # #         #                 # displayTime: 'auto',
        # onScanFailure = (error)->
        #     # console.warn(`Code scan error = ${error}`);
        #     console.log("Code found = #{decodedText}")

        # , 1000)
        
        Meteor.setTimeout =>
            # console.log 'generate', generate
            # qrScanner = new QrScanner(this.videoElem, result => console.log('decoded qr code:', result));
            
            #  console.log(Html5QrcodeScanner);
            
            # onScanSuccess = _.throttle((decodedText, decodedResult)->
            #     console.log("Code found = #{decodedText}")
            #     if Session.get('selected_cart_id')
            #         Meteor.call 'find_product_from_title',decodedText,(err,res)->
            #             if res 
            #                 console.log 'found product', res
            #         found_product = 
            #             Docs.findOne 
            #                 model:'product'
            #                 title:decodedText
                            
            #         if found_product
            #             console.log 'found product', found_product
            #             existing_cart_item = 
            #                 Docs.findOne 
            #                     model:'cart_item'
            #                     product_title:found_product.title
            #                     cart_id:Session.get('selected_cart_id')
            #             if existing_cart_item
            #                 Docs.update existing_cart_item._id, 
            #                     $inc:amount:1
            #     else 
            #         $('body').toast(
            #             showIcon: 'cart plus'
            #             message: "#{decodedText} detected but no shopping cart"
            #             # showProgress: 'bottom'
            #             class: 'error'
            #             # displayTime: 'auto',
            #             position: "top right"
            #         )
            #     $('body').toast(
            #         showIcon: 'plus'
            #         # message: "#{decodedText} amount increased"
            #         message: "#{decodedText} already added"
            #         # showProgress: 'bottom'
            #         class: 'info'
            #         actions:	[{
            #           text: 'Yes',
            #           icon: 'check',
            #           class: 'green',
            #           click: ()->
            #               $('body').toast({message:'You clicked "yes", toast closes by default'});
            #         },{
            #           icon: 'ban',
            #           class: 'icon red'
            #         },{
            #           text: '?',
            #           class: 'blue',
            #           click: ()->
            #               $('body').toast({message:'Returning false from the click handler avoids closing the toast '});
            #               return false;
            #         }]
            #         # displayTime: 'auto',
            #         position: "top right"
            #       )
            #     #     else
            #     #         Docs.insert 
            #     #             model:'cart_item'
            #     #             cart_id:Session.get('selected_cart_id')
            #     #             product_id:found._id
            #     #             product_title:found.title
            #     #             product_image_id:found.image_id
            #     #             amount:1
            #     #         $('body').toast(
            #     #             showIcon: 'cart plus'
            #     #             message: "#{decodedText} added to cart"
            #     #             # showProgress: 'bottom'
            #     #             class: 'success'
            #     #             position: "top right"
            #     #         )
            #     # else 
            #     #     console.log 'No found product'
            # , 1500)
                    
            # onScanFailure = (error)->
            # //   console.warn(`Code scan error = ${error}`);
            
            # html5QrcodeScanner = new Html5QrcodeScanner(
            #     "reader",
            #     { fps: 10, qrbox: {width: 300, height: 300}, facingMode: "environment" },
            #     false);
            # html5QrcodeScanner.render(onScanSuccess, onScanFailure);
            
            
            html5QrCode = new Html5Qrcode(
              "reader", {})
            qrCodeSuccessCallback =  _.throttle((decodedText, decodedResult)=>
                console.log 'sucess read', decodedText
                Session.set('just_read', true)
                Meteor.setTimeout( ->
                    Session.set('just_read', false)
                ,1500)
                $('body').toast(
                    # showIcon: 'checkmark'
                    # message: "#{decodedText} amount increased"
                    message: "#{decodedText} scanned"
                    # showProgress: 'bottom'
                    # classActions: 'left vertical attached',
                    class: 'black'
                    # classActions: 'basic left',
                    actions: [{
                        text: 'Undo',
                        icon:'undo'
                        class: 'red',
                        click: ()->
                            $('body').toast({message:'You clicked "undo", cart item removed'});
                    }]
                    # displayTime: 'auto',
                    # position: "top right"
                  )
                
            , 1500)
            config = { fps: 10, qrbox: { width: 300, height: 300 } };
            
            html5QrCode.start({ facingMode: "environment" }, config, qrCodeSuccessCallback);
            
            
        , 250
        
    Template.scanner.onCreated ->
        @autorun -> Meteor.subscribe 'scanner_products', ->
        @autorun -> Meteor.subscribe 'cart_items', ->
        @autorun -> Meteor.subscribe 'shopping_carts', ->
    Template.scanner.helpers
        column_class: ->
            if Session.get('just_read')
                "green inverted segment"
        add_item_class: -> if Session.get('is_adding_item') then 'blue' else 'basic'
        is_adding: -> Session.get('is_adding_item')
        selected_cart: -> Session.get('selected_cart_id')
        shopping_cart_button_class:->
            if Session.equals('selected_cart_id',@_id) then 'active large' else 'basic'
        shopping_cart_docs: ->
            Docs.find 
                model:'shopping_cart'
        test_products: ->
            Docs.find 
                model:'product'
        cart_items: ->
            Docs.find 
                cart_id:Session.get('selected_cart_id')
                model:'cart_item'
    Template.scanner.events
        'click .checkout': (e,t)->
            Docs.update @_id, 
                $set:status:'checkout'
            Router.go "/cart/#{Session.get('selected_cart_id')}/checkout"
            
            
        "click .add_item": (e,t)->
            if Session.equals('is_adding_item',true)
                Session.set('is_adding_item', false)
            else 
                Session.set('is_adding_item', true)
        "click .select_cart": (e,t)->
            if Session.equals('selected_cart_id',@_id)
                Session.set('selected_cart_id', null)
            else 
                Session.set('selected_cart_id', @_id)
        "click .new_cart": (e,t)->
            title = prompt('customer name?')
            if title 
                Docs.insert 
                    model:'shopping_cart'
                    name:title
        "click .gen_code": (e,t)->
            console.log @
            t.qrcode = new QRCode(document.getElementById("qrcode"), {
                text: @title,
                width: 250,
                height: 250,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
            })
        
        'click .remove_cart_item': (e,t)-> 
            if confirm "remove #{@title}?"
                Docs.remove @_id
        'click .clear_code': (e,t)-> 
            $('#qrcode').empty()
            console.log t
            t.qrcode.clear()
        # 'click .add_code': ->
        #     t.qrcode.makeCode("http://naver.com")
            
        "click .stop": (e,t)->
            $('#reader').empty()
            # t.html5QrcodeScanner.stop().then((ignore)->
            #   console.log 'stopped'
            # ).catch((err) =>
            # );
            
        "click .start": ()->
    Template.product_picker.onCreated ->
        @autorun => @subscribe 'product_search_results', Session.get('product_search'), ->

    Template.product_picker.helpers
        product_results: ->
            Docs.find {
                model:'product'
                title: {$regex:"#{Session.get('product_search')}",$options:'i'}
                
            }, sort:title:1
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
            if true
                if target["#{ref_field.key}"]
                    if @ref_field is target["#{ref_field.key}"] then 'active' else ''
                else ''
            else
                if parent["#{ref_field.key}"]
                    if @slug is parent["#{ref_field.key}"] then 'active' else ''
                else ''
    
    
    Template.product_picker.events
        'keyup .search_product': (e,t)->
            search = t.$('.search_product').val().trim()
            if search.length > 1
                Session.set('product_search', search)
                # doc = Docs.findOne parent._id
                # t.$('.search_product').val('')
                console.log 'search', search
                # Meteor.call 'log_term', search, ->
                # $('.search_product').val('')
                # Session.set('product_search', null)

        'click .select_choice': ->
            Session.set('product_search', null)
            new_id = 
                Docs.insert 
                    model:'cart_item'
                    cart_id:Session.get('selected_cart_id')
                    product_id:@_id
                    product_title:@title
                    product_image_id:@image_id
                    amount:1
    
        
if Meteor.isServer 
    Meteor.methods 
        find_product_from_title: (title)->
            found = Docs.findOne title
    Meteor.publish 'scanner_products', ->
        Docs.find(
            model:'product'
            app:'nf'
        , limit:10)
        
        
    Meteor.publish 'shopping_carts', ->
        Docs.find(
            model:'shopping_cart'
            # app:'nf'
            # product_title:$exists:true
        , {limit:10, sort:'_timestamp':-1})
        
    Meteor.publish 'product_search_results', (query)->
        Docs.find {
            model:'product'
            title: {$regex:"#{query}",$options:'i'}
        }, limit:10