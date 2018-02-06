# cross ratio for 4 numbers
function crossratio(a,b,c,d)
    d_ab = norm(a - b)
    d_bd = norm(b - d)
    d_ac = norm(a - c)
    d_cd = norm(c - d)
    (d_ab/d_bd)/(d_ac/d_cd)
end
export crossratio


# modulo that starts from one
# imod(1,3) = 1
# imod(2,3) = 2
# imod(3,3) = 3
# imod(4,3) = 1
function imod(i, n)
  return (i-1)%n + 1
end
export imod

#TODO handle zero deviation
# l1 = [(x1,y1), (x2,y2)]
# l2 = [(x3,y3), (x4,y4)]
function intersection_point(l1, l2)
  x1 = l1[1][1]
  y1 = l1[1][2]

  x2 = l1[2][1]
  y2 = l1[2][2]

  x3 = l2[1][1]
  y3 = l2[1][2]

  x4 = l2[2][1]
  y4 = l2[2][2]

  denominator = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)
  x = (x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4)
  y = (x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4)
  return [x,y]/denominator
end
export intersection_point

"""
    calcualte_rigid(source_pts,target_pts)

find (R,T) rigid transformation matrix and translation vector
such that target_pts ≈ R * source_pts + T
in the least-square sense
"""
function rigid_trans(src_pts,dst_pts)
  to_array(vv) = [vv[i][j] for i=1:length(vv) , j=1:length(vv[1])]
  n = length(src_pts)
  dim = size(src_pts[1])[1]
  dst_bar = mean(dst_pts)
  src_bar = mean(src_pts)
  dst_centered = dst_pts .- [dst_bar]
  src_centered = src_pts .- [src_bar]

  C = to_array(src_centered)' * to_array(dst_centered) / n
  U,s,V = svd(C)
  # Rotation R in least squares sense:
  Rr = (U * diagm(vcat(ones(dim-1), det(U*V.'))) * V.' ).'
  Tr = -Rr*src_bar + dst_bar

  Pr = PM(Rr,Tr)
  reproj_error = mean(norm.([Rr] .* src_pts .+ [Tr] - dst_pts))
  (Rr,Tr,reproj_error)
end
export rigid_trans
