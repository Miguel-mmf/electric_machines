 % Create some data for the two curves to be plotted
 x  = 0:0.01:20;
 y1 = 200*exp(-0.05*x).*sin(x);
 y2 = 0.8*exp(-0.5*x).*sin(10*x);

 % Create a plot with 2 y axes using the plotyy function
 figure;
 [ax, h1, h2] = plotyy(x, y1, x, y2, 'plot');

 % Add title and x axis label
 xlabel('Time (s)');
 title('Frequency Response');

 % Use the axis handles to set the labels of the y axes
 set(get(ax(1), 'Ylabel'), 'String', 'Low Frequency');
 set(get(ax(2), 'Ylabel'), 'String', 'High Frequency');

 %--PLOTLY--%
 p = fig2plotly; % <-- converts the yy-plot to an interactive, online version.

 %--URL--%
 % p.url = 'https://plot.ly/~matlab_user_guide/1522'
