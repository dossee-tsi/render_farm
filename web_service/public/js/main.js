$(function(){
    $('.open').click(function(){
        task = getTask(this);
        $.get('/tasks/' + getId(this),
            function(data)
            {
                var dialog = $('<dl></dl>');
                dialog.append('<dt>Render Time:</dt>')
                    .append('<dd>' + data.render_time + '</dd>')
                    .append('<dt>Directory:</dt>')
                    .append('<dd><input type="text" value="' + data.directory + '" />')
                    .dialog({title: 'Task Info',
                        modal: true,
                        buttons: {
                            'Close': function(){
                                $(this).dialog('close');
                            }
                        },
                        width: 400
                    });
            },
            'json');

    });
    
    $('.accept').click(function(){
        var task = getTask(this);
        disableButtons(task);
        $.post('/tasks/' + getId(this),
            { action: 'accept' },
            function(data){
                if (data.status == 'accepted')
                {
                    task.attr('class', 'accepted');
                    task.find('td:first + td').text('Accepted');
                    task.find('.reject').removeAttr('disabled');
                }
            },
            'json');
    });
    
    $('.reject').click(function(){
        var task = getTask(this);
        disableButtons(task);
        $.post('/tasks/' + getId(this),
            { action: 'reject' },
            function(data){
                if (data.status == 'rejected')
                {
                    task.remove();
                }
            },
            'json');
    });

    function disableButtons(task)
    {
        $(task).find('.accept').attr('disabled', 'disabled');
        $(task).find('.reject').attr('disabled', 'disabled');
    }

    function getId(el)
    {
        return $(el).parent().parent().attr('id').substring(4, 44);
    }

    function getTask(el)
    {
        return $(el).parent().parent();
    }

    function getTaskById(id)
    {
        return $('#task' + id);
    }
});
