Virtual Business Card
	Set up the project
		Create a new folder for your project.
			"D:\GitHub\github\Virtual_Business_Card"
		Open VSCode and navigate to the project folder.
		Create two new files: index.html and style.css.
			"D:\GitHub\github\Virtual_Business_Card\index.html"
			"D:\GitHub\github\Virtual_Business_Card\style.css"
	HTML structure
		I just ended up using a boilerplate from an extension previously downloaded. 
	Business card content
		Inside the body section, create a div element with a class or ID to serve as the container for the business card.
			        <div class="business-card"></div>

		Within the container, add elements such as h1 for your name, h2 for your job title or role, and p for additional information like your email, phone number, and website.
			<h1>Eric Davis</h1>
			            <h2>Web Developer</h2>
			            <p>Email: <a href="mailto:eric.jada.8825@gmail.com"> eric.jada.8825@gmail.com</a></p>
			            <p>Website: <a href="https://sites.google.com/view/eric-davis"></a></p>
	Styling with CSS
		Link the CSS file to the HTML file by adding a link tag in the head section of index.html.
			        <link rel="stylesheet" href="Virtual_Business_Card\style.css">
		Select the container div using its class or ID, and apply styles like background color, padding, margin, and width to give it a visually appealing look.
			.business-card {
  background-color: #f2f2f2;
  padding: 20px;
  margin: 20px;
  width: 300px;
}

		Style the text elements (e.g., h1, h2, p) by selecting them and setting properties like font size, font family, color, and alignment.
			.business-card h1 {
  font-size: 24px;
  color: #333;
  font-family: Arial, sans-serif;
}
			.business-card h2 {
  font-size: 18px;
  color: #777;
  font-family: Arial, sans-serif;
}
			.business-card p {
  font-size: 14px;
  color: #555;
  font-family: Arial, sans-serif;
}
		Experiment with additional CSS properties to enhance the design, such as borders, shadows, and transitions.
			border: 1px solid #ddd;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease-in-out;
	Preview and iterate
		Open index.html in a web browser to preview your virtual business card.
		Make adjustments to the HTML and CSS as needed to achieve the desired design.
		Continue previewing and refining until you're satisfied with the final result.
	Optional enhancements
		Consider adding responsive design using media queries to ensure your business card looks good on different screen sizes.
		Add social media icons or links to your profiles.
		Include a profile picture or logo.
			<div class="profile-picture">
                <img src="D:\GitHub\github\Virtual_Business_Card\profile_picture\20230603_145356.2.png" alt="Profile Picture">
              </div>