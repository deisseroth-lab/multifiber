function saveFigure(h, fname);

set(gcf,'Units','points');
set(gcf,'PaperUnits','points') 


size = get(gcf,'Position');
size = size(3:4);
set(gcf,'PaperSize',size)


set(gcf,'PaperPosition',[0,0,size(1),size(2)])
print(h,fname,'-dpng');
    
