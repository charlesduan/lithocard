settings.tex = "xelatex";
texpreamble("\usepackage{fontspec}");
texpreamble("\setmainfont{Libertinus Serif}");

pair paper = (5.5, 8.5);
pair margins = (0.75, 1.25);
pair card = (3.0, 4.0);
pair window_bar = (0.25, 0.25);

unitsize(1inch);

path centered_rect(pair center, pair dimens) {
    return shift(center) * scale(dimens.x, dimens.y)
        * ((-0.5, -0.5)--(0.5, -0.5)--(0.5, 0.5)--(-0.5, 0.5)--cycle);
}

path[] window_glass(real length) {
    path ctr_path = rotate(30) * scale(length) * ((-0.5, 0) -- (0.5, 0));
    return new path[] {
        shift(length * (-0.25, 0.25)) * scale(2) * ctr_path,
        ctr_path,
        shift(length * (0.25, -0.25)) * scale(1.1) * ctr_path,
    };
}

void pane_rect(transform pane_trans, bool glass = false) {
    pair win_ctr = 0.5paper;
    pair pane_size = (paper - 2margins  - 3window_bar) / 2;
    pair pane_offset = 0.5pane_size + 0.5window_bar;

    pair pane_ctr = win_ctr + pane_trans * pane_offset;
    draw(centered_rect(pane_ctr, pane_size));

    if (glass) {
        pair pane_corner = win_ctr + pane_trans * (
            pane_size + .5window_bar - 0.21pane_size.x * (1, 1)
        );
        draw(shift(pane_corner) * window_glass(0.15pane_size.x));
    }
}

path tree(
    real step_height,
    real slope = 4,
    int steps = 3,
    real inset_slope = 1.75
) {
    path res = (step_height / inset_slope, step_height * (steps - 1))
            .. {-1, slope} (0, steps * step_height);
    for (int i = 1; i < steps; ++i) {
        pair start = point(res, 0);
        pair next_down = start + (step_height / slope, -step_height);
        pair next_up = next_down + (-step_height / inset_slope, step_height);
        res = next_down .. {-1, slope}next_up -- res;
    }
    return (xscale(-1) * res) & reverse(res);
}

path trunk(path tree_path, real width, real height, real offset = 0.3) {
    path t_path = (-0.5width, 0) -- (-0.5width, height);
    return (-0.5width, 0) -- (-0.5width, height)
        .. {left} (shift(0, height * (1 - offset)) * tree_path) {left}
        .. (0.5width, height) -- (0.5width, 0);

}

pair window = paper - 2margins;

//
// Hills
//

void draw_hill(pair center, pair size) {
    path p = shift(center) * ((-size.x, 0){dir(20)} .. {right}(0, size.y));
    fill(center -- p -- cycle, white);
    draw(p);
}

pair center_bottom = (0.5paper.x, margins.y);
draw_hill(center_bottom + (1.8, 0.7), (2.5, 2));
draw_hill(center_bottom + (1, 0.5), (2.5, 1.4));


//
// Tree
//

path tree_path = shift(margins + scale(0.3, 0.1) * window) * trunk(
    tree(0.75, steps = 4, inset_slope = 1.6),
    0.4, 0.75
);

fill(tree_path -- cycle, white);
draw(tree_path);

//
// Snow
//
srand(2);
for (int i = 0; i < 50; ++i) {
    pair randpoint = scale(0.9window.x, 0.7window.y) * (unitrand(), unitrand())
        + margins + (0.05window.x, 0.29window.y);
    filldraw(circle(randpoint, 0.02), fillpen=white);
}


//
// Window bars
//

for (int i = -1; i <= 1; ++i) {
    pair double_corner = paper + i * (window - window_bar);
    fill(centered_rect(
        0.5(paper.x, double_corner.y), (window.x, window_bar.y)
    ), gray(0.95));
    fill(centered_rect(
        0.5(double_corner.x, paper.y), (window_bar.x, window.y)
    ), gray(0.95));
}

draw(centered_rect(0.5paper, window));
pane_rect(identity);
pane_rect(reflect((0, 0), (1, 0)), true);
pane_rect(reflect((0, 0), (0, 1)), true);
pane_rect(rotate(180));

/*
draw(centered_rect(0.5paper, card), p=dotted);

real slash_offset = 0.25;
for (int i = -1; i <= 1; i += 2) {
    draw(
        shift(0.5paper + i * (0.5card - slash_offset * (1, 1)))
        * scale(1.4 * slash_offset)
        * ((-1, 1)--(1, -1))
    );
}
*/

label(
    "\shortstack[c]{{\Large\emph{Happy Holidays!}}\\[6pt]"
    "From Alex, Theodore, Jenny, and Charles}",
    (0.5paper.x, paper.y - 0.5margins.y)
);
label(
    "\shortstack[c]{Remove the blue card and put it on your window,"
    "\\ or hold it in front of a light}",
    (0.5paper.x, 0.5margins.y));

add(shift(paper.x, 0) * currentpicture);
fixedscaling((0, 0), xscale(2) * paper);
