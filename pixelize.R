pixelize<-function(image_path,block_size){
  
  img <- image_read(image_path)
  img<-image_trim(img)
  
  pixel_array <- image_data(img) 
  
  # Convert hexadecimal to numeric
  R <- as.integer(paste0("0x", pixel_array[1, , ]))  # Red channel
  G <- as.integer(paste0("0x", pixel_array[2, , ]))  # Green channel
  B <- as.integer(paste0("0x", pixel_array[3, , ]))  # Blue channel
  
  pixel_df <- data.frame(
    x = rep(1:dim(pixel_array)[2], times = dim(pixel_array)[3]),  # Width repeats for height
    y = rep(1:dim(pixel_array)[3], each = dim(pixel_array)[2]),  # Height repeats for width
    R = R,
    G = G,
    B = B
  )
  
  pixel_df$color <- rgb(pixel_df$R, pixel_df$G, pixel_df$B, maxColorValue = 255)
  
  pixel_df <- pixel_df %>%
    mutate(
      block_x = (x - 1) %/% block_size + 1,  # Block ID for x
      block_y = (y - 1) %/% block_size + 1  # Block ID for y
      
    )
  
  reduced_pixel_df <- pixel_df %>%
    group_by(block_x, block_y) %>%
    summarise(
      R = mean(R),
      G = mean(G),
      B = mean(B),
      .groups = "drop"
    ) %>%
    mutate(
      color = rgb(R, G, B, maxColorValue = 255) , # Convert to hex color,
      alpha =runif(1),
      binary=sample(c(0, 1),size=n(),replace = T)
    )%>%
    filter(!(R >= 250 & G >= 250 & B >= 250))
  
  graph<-ggplot(reduced_pixel_df, aes(x = block_x, y = -block_y, color=color,fill = color)) +
    geom_tile(alpha=.85) +
    scale_fill_identity() +
    scale_colour_identity()+
    theme_void() +
    theme(legend.position = "none")+
    coord_fixed()
  
  graph
  
}
