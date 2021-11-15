if Meteor.isClient
    Router.route '/rental/:doc_id/', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'


if Meteor.isClient
    Router.route '/rentals', (->
        @layout 'layout'
        @render 'rentals'
        ), name:'rentals'


    Template.rentals.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'rental_sort_key', 'datetime_available'
        Session.setDefault 'rental_sort_label', 'available'
        Session.setDefault 'rental_limit', 5
        Session.setDefault 'view_open', true

    Template.rentals.onCreated ->
        @autorun => @subscribe 'rental_facets',
            picked_tags.array()
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'rental_results',
            picked_tags.array()
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go("/rental/#{new_id}/edit")


        'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .clear_picked_tags': ->
            Session.set('current_query',null)
            picked_tags.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_rental_count': ->
            Meteor.call 'calc_rental_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('rental_sort_direction') is -1
                Session.set('rental_sort_direction', 1)
            else
                Session.set('rental_sort_direction', -1)


    Template.rentals.helpers
        quickbuying_rental: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('rental_sort_direction')) is 1

        toggle_delivery_class: -> if Session.get('view_delivery') then 'blue' else ''
        toggle_pickup_class: -> if Session.get('view_pickup') then 'blue' else ''
        toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        connection: ->
            console.log Meteor.status()
            Meteor.status()
        connected: ->
            Meteor.status().connected
        invert_class: ->
            if Meteor.user()
                if Meteor.user().dark_mode
                    'invert'
        tags: ->
            # if Session.get('current_query') and Session.get('current_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            rental_count = Docs.find().count()
            # console.log 'rental count', rental_count
            if rental_count < 3
                Results.find({model:'tag', count: $lt: rental_count})
            else
                Results.find({model:'tag'})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        rental: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'rental'
            },
                sort: "#{Session.get('rental_sort_key')}":parseInt(Session.get('rental_sort_direction'))
                limit:Session.get('limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()





if Meteor.isServer
    Meteor.publish 'rental_results', (
        picked_tags
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        if doc_limit
            limit = doc_limit
        else
            limit = 10
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'rental', app:'nf'}
        if view_open
            match.open = $ne:false
        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'rental match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'rental_facets', (
        picked_tags
        picked_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'selected tags', picked_tags

        self = @
        match = {}
        match.model = 'rental'
        if view_open
            match.open = $ne:false

        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if picked_tags.length > 0 then match.tags = $all: picked_tags
            # match.$regex:"#{current_query}", $options: 'i'}
        # if query and query.length > 1
        # #     console.log 'searching query', query
        # #     # match.tags = {$regex:"#{query}", $options: 'i'}
        # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        # #
        #     Terms.find {
        #         title: {$regex:"#{query}", $options: 'i'}
        #     },
        #         sort:
        #             count: -1
        #         limit: 20
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: picked_tags }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if picked_tags.length > 0 then match.tags = $all: picked_tags
        # # match.tags = $all: picked_tags
        # # console.log 'match for tags', match
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: picked_tags }
        #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ], {
        #     allowDiskUse: true
        # }
        #
        # tag_cloud.forEach (tag, i) =>
        #     # console.log 'queried tag ', tag
        #     # console.log 'key', key
        #     self.added 'tags', Random.id(),
        #         title: tag.name
        #         count: tag.count
        #         # category:key
        #         # index: i


        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'tag result ', tag
            self.added 'tags', Random.id(),
                title: tag.title
                count: tag.count
                # category:key
                # index: i


        self.ready()


if Meteor.isClient
    Template.user_rentals.onCreated ->
        @autorun => Meteor.subscribe 'user_rentals', Router.current().params.username
    Template.user_rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"

    Template.user_rentals.helpers
        rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'rental'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_rentals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_id: user._id

if Meteor.isClient
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Session.set 'view_mode', 'cards'

    #     'click .calculate_diff': ->
    #         product = Template.parentData()
    #         console.log product
    #         moment_a = moment @start_datetime
    #         moment_b = moment @end_datetime
    #         reservation_hours = -1*moment_a.diff(moment_b,'hours')
    #         reservation_days = -1*moment_a.diff(moment_b,'days')
    #         hourly_reservation_price = reservation_hours*product.hourly_rate
    #         daily_reservation_price = reservation_days*product.daily_rate
    #         Docs.update @_id,
    #             $set:
    #                 reservation_hours:reservation_hours
    #                 reservation_days:reservation_days
    #                 hourly_reservation_price:hourly_reservation_price
    #                 daily_reservation_price:daily_reservation_price

    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id


    Template.reserve_button.events
        'click .new_reservation': (e,t)->
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
            Router.go "/reservation/#{new_reservation_id}/edit"


    Template.reservation_segment.events
        'click .calc_res_numbers': ->
            start_date = moment(@start_timestamp).date()
            start_month = moment(@start_timestamp).month()
            start_minute = moment(@start_timestamp).minute()
            start_hour = moment(@start_timestamp).hour()
            Docs.update @_id,
                $set:
                    start_date:start_date
                    start_month:start_month
                    start_hour:start_hour
                    start_minute:start_minute



if Meteor.isServer
    Meteor.publish 'rental_reservations_by_id', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id

    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
        rentals_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            rentals.return.push date_string
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            reservations = Docs.find({model:'reservation', rental_id:rental_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/reservation_count
            average_rental_duration = total_rental_hours/reservation_count

            Docs.update rental_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header rental ranking #reservations
            # .ui.small.header rental ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg rental time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date



if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'


    Template.rental_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500


    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.rental_edit.helpers
        viewing_content: ->
            Session.equals('expand_field', @_id)

    Template.rental_edit.events
        'click .field_edit': ->
            if Session.equals('expand_field', @_id)
                Session.set('expand_field', null)
            else
                Session.set('expand_field', @_id)



# Router.route '/rental/:doc_id/', (->
#     @render 'rental_view'
#     ), name:'rental_view'
# Router.route '/rental/:doc_id/edit', (->
#     @render 'rental_edit'
#     ), name:'rental_edit'
#
#
# if Meteor.isClient
#     Template.rental_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.rental_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#
#     Template.rental_history.onCreated ->
#         @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
#     Template.rental_history.helpers
#         rental_events: ->
#             Docs.find
#                 model:'log_event'
#                 parent_id:Router.current().params.doc_id
#
#
#     Template.rental_subscription.onCreated ->
#         # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
#     Template.rental_subscription.events
#         'click .subscribe': ->
#             Docs.insert
#                 model:'log_event'
#                 log_type:'subscribe'
#                 parent_id:Router.current().params.doc_id
#                 text: "#{Meteor.user().username} subscribed to rental order."
#
#
#     Template.rental_reservations.onCreated ->
#         @autorun => Meteor.subscribe 'rental_reservations', Router.current().params.doc_id
#     Template.rental_reservations.helpers
#         reservations: ->
#             Docs.find
#                 model:'reservation'
#                 rental_id: Router.current().params.doc_id
#     Template.rental_reservations.events
#         'click .new_reservation': ->
#             Docs.insert
#                 model:'reservation'
#                 rental_id: Router.current().params.doc_id
#
#
# if Meteor.isServer
#     Meteor.publish 'rental_reservations', (rental_id)->
#         Docs.find
#             model:'reservation'
#             rental_id: rental_id
#
#
#
#     Meteor.methods
#         calc_rental_stats: ->
#             rental_stat_doc = Docs.findOne(model:'rental_stats')
#             unless rental_stat_doc
#                 new_id = Docs.insert
#                     model:'rental_stats'
#                 rental_stat_doc = Docs.findOne(model:'rental_stats')
#             console.log rental_stat_doc
#             total_count = Docs.find(model:'rental').count()
#             complete_count = Docs.find(model:'rental', complete:true).count()
#             incomplete_count = Docs.find(model:'rental', complete:$ne:true).count()
#             Docs.update rental_stat_doc._id,
#                 $set:
#                     total_count:total_count
#                     complete_count:complete_count
#                     incomplete_count:incomplete_count


if Meteor.isClient
    # Calendar = require('tui-calendar');
    # require("tui-calendar/dist/tui-calendar.css");
    # require('tui-date-picker/dist/tui-date-picker.css');
    # require('tui-time-picker/dist/tui-time-picker.css');

    Template.rental_calendar.onCreated ->
        @autorun -> Meteor.subscribe 'rental_reservations_by_id', Router.current().params.doc_id
    Template.rental_calendar.onRendered ->
        # @calendar = new Calendar('#calendar', {
        #     # defaultView: 'month',
        #     defaultView: 'week',
        #     taskView: true,  # e.g. true, false, or ['task', 'milestone'])
        #     scheduleView: ['time']  # e.g. true, false, or ['allday', 'time'])
        #     month:
        #         daynames: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'],
        #         startDayOfWeek: 0,
        #         narrowWeekend: true
        #     week:
        #         daynames: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'],
        #         startDayOfWeek: 0,
        #         narrowWeekend: true
        #     template:
        #         monthGridHeader: (model)->
        #             date = new Date(model.date);
        #             template = '<span class="tui-full-calendar-weekday-grid-date">' + date.getDate() + '</span>';
        #             template;
        # })
        # if @subscriptionsReady()
        #     reservations = Docs.find(
        #         model:'reservation'
        #     ).fetch()
        #     console.log reservations
        #     id = '1'
        #     converted_schedules = []
        #     for res in reservations
        #         converted_schedules.push {
        #             id: toString(id)
        #             calendarId: '1'
        #             title: 'title'
        #             # title: res._author_username
        #             category: 'time'
        #             # category: res._author_username
        #             dueDateClass: ''
        #             # start: '2019-10-10T02:30:00+09:00',
        #             # end: '2019-10-10T02:50:00+09:00'
        #             start: res.start_datetime
        #             end: res.end_datetime
        #         }
        #         id++
        #     converted_schedules.push {
        #         id: '1',
        #         calendarId: '1',
        #         title: 'my schedule',
        #         category: 'time',
        #         dueDateClass: '',
        #         start: '2019-10-11T02:30:00',
        #         end: '2019-10-11T05:50:00'
        #     }
        #     converted_schedules.push {
        #         id: '2',
        #         calendarId: '1',
        #         title: 'second schedule',
        #         category: 'time',
        #         dueDateClass: '',
        #         start: '2019-10-10T09:30:00+09:00',
        #         end: '2019-10-10T09:50:00+09:00'
        #     }
        #     console.log converted_schedules
        #     @calendar.createSchedules( converted_schedules )
        # $('#calendar').fullCalendar();
        # calendarEl = document.getElementById('calendar');
        #
        # calendar = new Calendar(calendarEl, {
        #     plugins: [ dayGridPlugin, timeGridPlugin, listPlugin ]
        # });
        #
        # calendar.render();

        Template.rental_calendar.helpers
            # calendarOptions: ->
            #     # // While developing, in order to hide the license warning, use the following key
            #     schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
            #     # // Standard fullcalendar options
            #     height: 700,
            #     hiddenDays: [ 0 ],
            #     slotDuration: '01:00:00',
            #     minTime: '08:00:00',
            #     maxTime: '19:00:00',
            #     lang: 'fr',
            #     # // Function providing events reactive computation for fullcalendar plugin
            #     events: (start, end, timezone, callback)->
            #         console.log(start.format(), end.format());
            #         # // Get events from the CalendarEvents collection
            #         # // return as an array with .fetch()
            #         events = Docs.find({
            #              "id"         : "calendar1",
            #              "startValue" : { $gte: start.valueOf() },
            #              "endValue"   : { $lte: end.valueOf() }
            #         }).fetch();
            #         # callback(events);
            #     # // Optional: id of the calendar
            #     id: "calendar1",
            #     # // Optional: Additional cl to apply to the calendar
            #     addedcl: "col-md-8",
            #     # // Optional: Additional functions to apply after each reactive events computation
            #     autoruns: [
            #         ()->
            #             console.log("user defined autorun function executed!");
            #     ]

        rental: -> Docs.findOne Router.current().params.doc_id
        current_hour: -> Session.get('current_hour')
        current_date_string: -> Session.get('current_date_string')
        current_date: -> Session.get('current_date')
        current_month: -> Session.get('current_month')
        hourly_reservation: ->
            # day_moment_ob = Template.parentData().data.moment_ob
            # # start_date = day_moment_ob.format("YYYY-MM-DD")
            # start_date = day_moment_ob.date()
            # start_month = day_moment_ob.month()
            # start_hour = parseInt(@.valueOf())
            start_date = parseInt Session.get('current_date')
            start_hour = parseInt Session.get('current_hour')
            start_month = parseInt Session.get('current_month')
            Docs.findOne {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }

        upcoming_days: ->
            upcoming_days = []
            now = new Date()
            today = moment(now).format('dddd MMM Do')
            # upcoming_days.push today
            day_number = 0
            # for day in [0..3]
            for day in [0..1]
                day_number++
                moment_ob = moment(now).add(day, 'days')
                long_form = moment(now).add(day, 'days').format('dddd MMM Do')
                upcoming_days.push {moment_ob:moment_ob,long_form:long_form}
            upcoming_days

    Template.rental_calendar.events
        # 'click .next_view': (e,t)->
        #     t.calendar.next()
        # 'click .create_schedules': (e,t)->
        #     reservations = Docs.find(
        #         model:'reservation'
        #     ).fetch()
        #     console.log reservations
        #     id = '1'
        #     converted_schedules = []
        #     for res in reservations
        #         converted_schedules.push {
        #             id: toString(id)
        #             calendarId: '1'
        #             title: 'title'
        #             # title: res._author_username
        #             category: 'time'
        #             # category: res._author_username
        #             dueDateClass: ''
        #             # start: '2019-10-10T02:30:00+09:00',
        #             # end: '2019-10-10T02:50:00+09:00'
        #             start: res.start_datetime
        #             end: res.end_datetime
        #         }
        #         id++
        #     console.log converted_schedules
        #     t.calendar.createSchedules( converted_schedules )
        #
        # 'click .prev_view': (e,t)->
        #     t.calendar.prev()
        # 'click .view_day': (e,t)->
        #     t.calendar.changeView('day', true);
        # 'click .view_week': (e,t)->
        #     t.calendar.changeView('week', true);
        # 'click .move_now': (e,t)->
        #     # if t.calendar.getViewName() isnt 'month'
        #     t.calendar.scrollToNow()
        # 'click .view_month': (e,t)->
        #     # // monthly view(default 6 weeks view)
        #     t.calendar.setOptions({month: {visibleWeeksCount: 6}}, true); # or null
        #     t.calendar.changeView('month', true);


        'click .reserve_this': ->
            rental = Docs.findOne Router.current().params.doc_id
            current_month = parseInt Session.get('current_month')
            current_date = parseInt Session.get('current_date')
            current_minute = parseInt Session.get('current_minute')
            current_date_string = Session.get('current_date_string')
            current_hour = parseInt Session.get('current_hour')
            start_datetime = "#{current_date_string}T#{current_hour}:00"
            end_datetime = "#{current_date_string}T#{current_hour+1}:00"
            start_time = "#{current_hour}:00"
            end_time = moment(@start_datetime).add(1,'hours').format("HH:mm")

            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: rental._id
                start_hour: current_hour
                start_minute: 0
                start_date_string: current_date_string
                start_date: current_date
                start_month: current_month
                start_datetime: start_datetime
                end_datetime: end_datetime
                start_time: start_time
                end_time: end_time
                hour_duration: 1
            Meteor.call 'recalc_reservation_cost', new_reservation_id

    Template.reservation_small.helpers
        is_paying: -> Session.get 'paying'
        can_buy: -> Meteor.user().credit > @total_cost
        need_credit: -> Meteor.user().credit < @total_cost
        need_approval: -> @friends_only and Meteor.userId() not in @author.friend_ids
        submit_button_class: ->
            if Session.get 'paying'
                'disabled'
            else if @start_datetime and @end_datetime
                 ''
            else 'disabled'
        member_balance_after_reservation: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost+rental.security_deposit_amount).toFixed(2)
        member_balance_after_purchase: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost).toFixed(2)

    Template.reservation_small.onCreated ->

    Template.reservation_small.events
        'click .trigger_recalc': ->
            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id
            $('.handler')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })
            $('.result')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })

        'change .res_start_time': (e,t)->
            val = t.$('.res_start_time').val()
            Docs.update @_id,
                $set:start_time:val
            Meteor.call 'recalc_reservation_cost', Template.parentData().doc_id

        'change .res_end_time': (e,t)->
            val = t.$('.res_end_time').val()
            Docs.update @_id,
                $set:end_time:val
            Meteor.call 'recalc_reservation_cost', Template.parentData().doc_id

        'change .hour_duration': (e,t)->
            val = parseFloat(t.$('.hour_duration').val())
            val_int = parseInt(t.$('.hour_duration').val())
            console.log val
            console.log moment(@start_datetime).add(val,'hours').format("HH:mm")
            end_time = moment(@start_datetime).add(val,'hours').format("HH:mm")
            end_datetime = moment(@start_datetime).add(val,'hours').format("YYYY-MM-DD[T]HH:00")
            end_hour = moment(@start_datetime).add(val,'hours').hour()
            console.log end_datetime
            Docs.update @_id,
                $set:
                    hour_duration:val
                    end_time:end_time
                    end_hour: end_hour
                    end_datetime:end_datetime
            Meteor.call 'recalc_reservation_cost', @_id

        'change .res_start': (e,t)->
            val = t.$('.res_start').val()
            Docs.update @_id,
                $set:start_datetime:val
            Meteor.call 'recalc_reservation_cost', @_id

        'change .res_end': (e,t)->
            val = t.$('.res_end').val()
            Docs.update @_id,
                $set:end_datetime:val
            Meteor.call 'recalc_reservation_cost', @_id

        'click .submit_reservation': ->
            Session.set 'paying', true
            # Docs.update @_id,
            #     $set:
            #         submitted:true
            #         submitted_timestamp:Date.now()
            Meteor.call 'pay_for_reservation', @_id, =>
                Session.set 'paying', false
                Router.go "/reservation/#{@_id}/"



    Template.upcoming_day.events
        'click .select_hour': ->
            day_moment_ob = Template.parentData().moment_ob

            hour = parseInt(@.valueOf())
            Session.set('current_hour', hour)

            date_string = day_moment_ob.format("YYYY-MM-DD")
            Session.set('current_date_string', date_string)

            date = day_moment_ob.date()
            Session.set('current_date', date)

            month = day_moment_ob.month()
            Session.set('current_month', month)

    Template.upcoming_day.helpers
        hours: -> [7..20]
        hour_display: ->
            # console.log @
            if @ < 11.9
                "#{@}am"
            else if @ < 12.1
                "#{@}pm"
            else
                "#{@-12}pm"


        hour_class: ->
            cl = ''
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            found_res = Docs.findOne {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }
            if found_res and found_res.submitted
                cl += 'tertiary'
            date = day_moment_ob.date()
            if Session.equals('current_hour', hour)
                if Session.equals('current_date', date)
                    cl += ' active blue'
            cl
        pending_res: ->
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            found_res = Docs.findOne {
                model:'reservation'
                submitted: $ne: true
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }

        existing_reservations: ->
            day_moment_ob = Template.parentData().data.moment_ob
            # start_date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            Docs.find {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }
            
            
if Meteor.isClient
    Router.route '/reservation/:doc_id/', (->
        @render 'reservation_view'
        ), name:'reservation_view'
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id, ->


    # Template.rental_view_reservations.onCreated ->
    #     @autorun -> Meteor.subscribe 'rental_reservations',
    #         Template.currentData()
    #         Session.get 'res_view_mode'
    #         Session.get 'date_filter'
    # Template.rental_view_reservations.helpers
    #     reservations: ->
    #         Docs.find {
    #             model:'reservation'
    #         }, sort: start_datetime:-1
    #     view_res_cards: -> Session.equals 'res_view_mode', 'cards'
    #     view_res_segments: -> Session.equals 'res_view_mode', 'segments'
    # Template.rental_view_reservations.events
    #     'click .set_card_view': -> Session.set 'res_view_mode', 'cards'
    #     'click .set_segment_view': -> Session.set 'res_view_mode', 'segments'

    Template.reservation_events.onCreated ->
        @autorun => Meteor.subscribe 'log_events', Router.current().params.doc_id
    Template.reservation_events.helpers
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id

    # Template.rental_stats.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000

    # Template.rental_view_reservations.onRendered ->
    #     Session.setDefault 'view_mode', 'cards'


    # Template.set_date_filter.events
    #     'click .set_date_filter': -> Session.set 'date_filter', @key
    #
    # Template.set_date_filter.helpers
    #     date_filter_class: ->
    #         if Session.equals('date_filter', @key) then 'active' else ''


if Meteor.isServer
    Meteor.publish 'rental_reservations', (rental, view_mode, date_filter)->
        console.log view_mode
        console.log date_filter
        Docs.find
            model:'reservation'
            rental_id: rental._id


    Meteor.publish 'log_events', (parent_id)->
        Docs.find
            model:'log_event'
            parent_id:parent_id

    Meteor.publish 'reservations_by_product_id', (product_id)->
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'rental_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        if reservation
            Docs.find
                model:'rental'
                _id: reservation.rental_id

    Meteor.publish 'owner_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        rental =
            Docs.findOne
                model:'rental'
                _id: reservation.rental_id

        Meteor.users.find
            _id: rental.owner_username

    Meteor.publish 'handler_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        rental =
            Docs.findOne
                model:'rental'
                _id: reservation.rental_id

        Meteor.users.find
            _id: rental.handler_username

    Meteor.methods
        calc_reservation_stats: ->
            reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            unless reservation_stat_doc
                new_id = Docs.insert
                    model:'reservation_stats'
                reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            console.log reservation_stat_doc
            total_count = Docs.find(model:'reservation').count()
            submitted_count = Docs.find(model:'reservation', submitted:true).count()
            current_count = Docs.find(model:'reservation', current:true).count()
            unsubmitted_count = Docs.find(model:'reservation', submitted:$ne:true).count()
            Docs.update reservation_stat_doc._id,
                $set:
                    total_count:total_count
                    submitted_count:submitted_count
                    current_count:current_count



if Meteor.isClient
    Router.route '/reservation/:doc_id/edit', (->
        @render 'reservation_edit'
        ), name:'reservation_edit'

    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'owner_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'handler_by_res_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'user_by_username', 'deb_sclar'



    Template.reservation_edit.helpers
        rental: -> Docs.findOne model:'rental'
        now_button_class: -> if @now then 'active' else ''
        sel_hr_class: -> if @duration_type is 'hour' then 'active' else ''
        sel_day_class: -> if @duration_type is 'day' then 'active' else ''
        sel_month_class: -> if @duration_type is 'month' then 'active' else ''
        is_month: -> @duration_type is 'month'
        is_day: -> @duration_type is 'day'
        is_hour: -> @duration_type is 'hour'

        is_paying: -> Session.get 'paying'

        can_buy: ->
            Meteor.user().credit > @total_cost

        need_credit: ->
            Meteor.user().credit < @total_cost

        need_approval: ->
            @friends_only and Meteor.userId() not in @author.friend_ids

        submit_button_class: ->
            if @start_datetime and @end_datetime then '' else 'disabled'

        member_balance_after_reservation: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost).toFixed(2)

        # diff: -> moment(@end_datetime).diff(moment(@start_datetime),'hours',true)

    Template.reservation_edit.events
        'click .add_credit': ->
            deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
            stripe_charge = parseFloat(deposit_amount)*100*1.02+20
            # stripe_charge = parseInt(deposit_amount*1.02+20)

            # if confirm "add #{deposit_amount} credit?"
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: stripe_charge

        'click .trigger_recalc': ->
            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id
            $('.handler')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })
            $('.result')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })

        'change .res_start': (e,t)->
            val = t.$('.res_start').val()
            Docs.update @_id,
                $set:start_datetime:val

        'change .res_end': (e,t)->
            val = t.$('.res_end').val()
            Docs.update @_id,
                $set:end_datetime:val

            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id


        'click .select_day': ->
            Docs.update @_id,
                $set: duration_type: 'day'
        'click .select_hour': ->
            Docs.update @_id,
                $set: duration_type: 'hour'
        'click .select_month': ->
            Docs.update @_id,
                $set: duration_type: 'month'

        'click .set_1_hr': ->
            Docs.update @_id,
                $set:
                    hour_duration: 1
                    end_datetime: moment(@start_datetime).add(1,'hour').format("YYYY-MM-DD[T]HH:mm")
            rental = Docs.findOne @rental_id
            hour_duration = 1
            cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # console.log diff
            taxes_payout = parseFloat((cost*.05)).toFixed(2)
            owner_payout = parseFloat((cost*.5)).toFixed(2)
            handler_payout = parseFloat((cost*.45)).toFixed(2)
            Docs.update @_id,
                $set:
                    cost: cost
                    taxes_payout: taxes_payout
                    owner_payout: owner_payout
                    handler_payout: handler_payout

        'change .other_hour': ->
            $('.result_column .header')
              .transition({
                animation : 'pulse',
                duration  : 200,
                interval  : 50
              })

            val = parseInt $('.other_hour').val()
            Docs.update @_id,
                $set:
                    hour_duration: val
                    end_datetime: moment(@start_datetime).add(val,'hour').format("YYYY-MM-DD[T]HH:mm")

            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id

            # rental = Docs.findOne @rental_id
            # hour_duration = val
            # cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # # console.log diff
            # taxes_payout = parseFloat((cost*.05)).toFixed(2)
            # owner_payout = parseFloat((cost*.5)).toFixed(2)
            # handler_payout = parseFloat((cost*.45)).toFixed(2)
            # Docs.update @_id,
            #     $set:
            #         cost: cost
            #         taxes_payout: taxes_payout
            #         owner_payout: owner_payout
            #         handler_payout: handler_payout
            # $('.result_column').transition('glow',500)


        'click .reserve_now': ->
            if @now
                Docs.update @_id,
                    $set:
                        now: false
            else
                now = Date.now()
                Docs.update @_id,
                    $set:
                        now: true
                        start_datetime: moment(now).format("YYYY-MM-DD[T]HH:mm")
                        start_timestamp: now

        'click .submit_reservation': ->
            $('.ui.modal')
            .modal({
                closable: true
                onDeny: ()->
                onApprove: ()=>
                    # Session.set 'paying', true
                    rental = Docs.findOne @rental_id
                    # console.log @
                    Docs.update @_id,
                        $set:
                            submitted:true
                            submitted_timestamp:Date.now()
                    Session.set 'paying', false
                    Meteor.call 'pay_for_reservation', @_id, =>
                        Session.set 'paying', true
                        Router.go "/reservation/#{@_id}/"
            }).modal('show')

        'click .unsubmit': ->
            Docs.update @_id,
                $set:
                    submitted:false
                    unsubmitted_timestamp:Date.now()
            Docs.insert
                model:'log_event'
                parent_id:Router.current().params.doc_id
                log_type:'reservation_unsubmission'
                text:"reservation unsubmitted by #{Meteor.user().username}"
            # Router.go "/reservation/#{@_id}/"

        'click .cancel_reservation': ->
            if confirm 'delete reservation?'
                Docs.remove @_id
                Router.go "/rental/#{@rental_id}/"


        #     rental = Docs.findOne @rental_id
        #     # console.log @
        #     Docs.update @_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #     Meteor.call 'pay_for_reservation', @_id, =>
        #         Router.go "/reservation/#{@_id}/"



if Meteor.isServer
    Meteor.methods
        recalc_reservation_cost: (res_id)->
            res = Docs.findOne res_id
            # console.log res
            rental = Docs.findOne res.rental_id
            hour_duration = moment(res.end_datetime).diff(moment(res.start_datetime),'hours',true)
            cost = parseFloat hour_duration*rental.hourly_dollars
            total_cost = cost
            taxes_payout = parseFloat((cost*.05))
            owner_payout = parseFloat((cost*.5))
            handler_payout = parseFloat((cost*.45))
            if rental.security_deposit_required
                total_cost += rental.security_deposit_amount
            if res.res_start_dropoff_selected
                total_cost += rental.res_start_dropoff_fee
                handler_payout += rental.res_start_dropoff_fee
            if res.res_end_pickup_selected
                total_cost += rental.res_end_pickup_fee
                handler_payout += rental.res_end_pickup_fee
            # console.log diff
            Docs.update res._id,
                $set:
                    hour_duration: hour_duration.toFixed(2)
                    cost: cost.toFixed(2)
                    total_cost: total_cost.toFixed(2)
                    taxes_payout: taxes_payout.toFixed(2)
                    owner_payout: owner_payout.toFixed(2)
                    handler_payout: handler_payout.toFixed(2)

        pay_for_reservation: (res_id)->
            res = Docs.findOne res_id
            # console.log res
            rental = Docs.findOne res.rental_id

            Meteor.call 'send_payment', Meteor.user().username, rental.owner_username, res.owner_payout, 'owner_payment', res_id
            Docs.insert
                model:'log_event'
                log_type: 'payment'

            Meteor.call 'send_payment', Meteor.user().username, rental.handler_username, res.handler_payout, 'handler_payment', res_id
            Meteor.call 'send_payment', Meteor.user().username, 'dev', res.taxes_payout, 'taxes_payment', res_id

            Docs.insert
                model:'log_event'
                parent_id:res_id
                res_id: res_id
                rental_id: res.rental_id
                log_type:'reservation_submission'
                text:"reservation submitted by #{Meteor.user().username}"

        send_payment: (from_username, to_username, amount, reason, reservation_id)->
            console.log 'sending payment from', from_username, 'to', to_username, 'for', amount, reason, reservation_id
            res = reservation_id
            sender = Meteor.users.findOne username:from_username
            recipient = Meteor.users.findOne username:to_username


            console.log 'sender', sender._id
            console.log 'recipient', recipient._id
            console.log typeof amount
            #
            amount  = parseFloat amount

            Meteor.users.update sender._id,
                $inc: credit: -amount

            Meteor.users.update recipient._id,
                $inc: credit: amount

            Docs.insert
                model:'payment'
                sender_username: from_username
                sender_id: sender._id
                recipient_username: to_username
                recipient_id: recipient._id
                amount: amount
                reservation_id: reservation_id
                rental_id: res.rental_id
                reason:reason
            Docs.insert
                model:'log_event'
                log_type: 'payment'
                sender_username: from_username
                recipient_username: to_username
                amount: amount
                recipient_id: recipient._id
                text:"#{from_username} paid #{to_username} #{amount} for #{reason}."
                sender_id: sender._id
            return            