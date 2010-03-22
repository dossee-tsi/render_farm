$(function(){
    $('.open').click(function(){
        task = getTask(this);
        $.get('/tasks/' + getHash(this),
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
                dialog.find('input').focus(function(){
                    $(this).select();
                })
                .mouseup(function(e){
                    e.preventDefault();
                });
            },
            'json');

    });
    
    $('.accept').click(function(){
        var task = getTask(this);
        disableButtons(task);
        $.post('/tasks/' + getHash(this),
            { status: 'accept' },
            function(data){
                if (data.status == 'accepted')
                {
                    task.find('.accept, .reject').addClass('invisible');
                    task.attr('class', 'accepted');
                    task.find('td:first + td').text('Accepted');
                }
            },
            'json');
    });
    
    $('.reject').click(function(){
        var task = getTask(this);
        disableButtons(task);
        $.post('/tasks/' + getHash(this),
            { status: 'reject' },
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
        $(task).find('.accept, .reject').attr('disabled', 'disabled');
    }

    function getHash(el)
    {
        return $(el).closest('tr').find('.hash').text();
    }

    function getTask(el)
    {
        return $(el).parent().parent();
    }

    function getTaskById(id)
    {
        return $('#task' + id);
    }

    $('.tasks button.open').button({
        icons: {
            primary: 'ui-icon-folder-open'
        }
    });
    $('.tasks button.accept').button({
        icons: {
            primary: 'ui-icon-check'
        }
    });
    $('.tasks button.reject').button({
        icons: {
            primary: 'ui-icon-close'
        }
    });
});
