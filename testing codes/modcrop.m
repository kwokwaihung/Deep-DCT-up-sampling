function imgs = modcrop(imgs, modulo)

% for i = 1:numel(imgs)
    sz = size(imgs);
    sz = sz - mod(sz, modulo);
    imgs = imgs(1:sz(1), 1:sz(2));
% end
