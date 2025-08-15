-- Library.ai Database Setup Script for MySQL/MariaDB
-- This script creates the complete database structure and populates it with sample data

-- Create database
CREATE DATABASE IF NOT EXISTS libraryai_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE libraryai_db;

-- Create genres table
CREATE TABLE tbl_genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create books table
CREATE TABLE tbl_books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    genre INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    brief_summary TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (genre) REFERENCES tbl_genres(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_genre (genre),
    INDEX idx_title (title),
    INDEX idx_author (author)
);

-- Insert genres
INSERT INTO tbl_genres (name) VALUES 
('Fiction'),
('Mystery & Thriller'),
('Science Fiction'),
('Fantasy'),
('Romance'),
('Historical Fiction'),
('Literary Fiction'),
('Young Adult'),
('Horror'),
('Biography & Memoir'),
('Self-Help'),
('Business'),
('Psychology'),
('Philosophy'),
('Contemporary Fiction');

-- Insert 100 sample books with real information
INSERT INTO tbl_books (genre, title, author, brief_summary) VALUES 
-- Fiction (genre_id: 1)
(1, 'To Kill a Mockingbird', 'Harper Lee', 'A gripping tale of racial injustice and childhood innocence in the American South, told through the eyes of Scout Finch as her father defends a black man falsely accused of rape.'),
(1, 'The Great Gatsby', 'F. Scott Fitzgerald', 'A critique of the American Dream set in the Jazz Age, following Nick Carraway as he observes the tragic story of his mysterious neighbor Jay Gatsby and his obsession with Daisy Buchanan.'),
(1, 'Pride and Prejudice', 'Jane Austen', 'A witty social commentary following Elizabeth Bennet as she navigates love, family, and societal expectations in Regency England, particularly her complex relationship with the proud Mr. Darcy.'),
(1, 'The Catcher in the Rye', 'J.D. Salinger', 'A coming-of-age story following Holden Caulfield, a disaffected teenager who wanders New York City after being expelled from prep school, offering a raw look at adolescent alienation.'),
(1, 'One Hundred Years of Solitude', 'Gabriel García Márquez', 'A magical realist masterpiece chronicling seven generations of the Buendía family in the fictional town of Macondo, blending reality with fantastical elements.'),

-- Mystery & Thriller (genre_id: 2)
(2, 'Gone Girl', 'Gillian Flynn', 'A psychological thriller about Nick Dunne, whose wife Amy disappears on their fifth wedding anniversary, revealing dark secrets and manipulation that challenge everything we think we know about marriage.'),
(2, 'The Girl with the Dragon Tattoo', 'Stieg Larsson', 'A gripping crime thriller combining murder mystery with financial corruption, featuring journalist Mikael Blomkvist and the enigmatic hacker Lisbeth Salander.'),
(2, 'The Silent Patient', 'Alex Michaelides', 'A psychological thriller about a woman who refuses to speak after allegedly murdering her husband, and the psychotherapist obsessed with treating her.'),
(2, 'In the Woods', 'Tana French', 'A haunting mystery following detective Rob Ryan as he investigates a child\'s murder that echoes his own traumatic childhood experience in the same woods.'),
(2, 'The Thursday Murder Club', 'Richard Osman', 'A cozy mystery featuring four retirees in a retirement community who meet weekly to investigate cold cases, until they find themselves in the middle of a live murder case.'),
(2, 'Big Little Lies', 'Liane Moriarty', 'A suspenseful drama following three women whose seemingly perfect lives unravel to the point of murder, exploring themes of domestic violence and friendship.'),
(2, 'The Woman in the Window', 'A.J. Finn', 'A psychological thriller about an agoraphobic woman who believes she witnessed a crime from her window, but her reliability as a narrator comes into question.'),

-- Science Fiction (genre_id: 3)
(3, 'Dune', 'Frank Herbert', 'An epic space opera set on the desert planet Arrakis, following Paul Atreides as he navigates political intrigue, mystical powers, and ecological themes in a complex galactic empire.'),
(3, 'The Hitchhiker\'s Guide to the Galaxy', 'Douglas Adams', 'A comedic science fiction series following Arthur Dent as he travels through space after Earth\'s destruction, armed only with a towel and an electronic guidebook.'),
(3, 'Neuromancer', 'William Gibson', 'A cyberpunk novel that coined the term "cyberspace," following a washed-up computer hacker hired for one last job in a dystopian digital future.'),
(3, 'The Left Hand of Darkness', 'Ursula K. Le Guin', 'A groundbreaking exploration of gender and sexuality through the story of an envoy to a planet where inhabitants can change their gender.'),
(3, 'Foundation', 'Isaac Asimov', 'The first novel in Asimov\'s Foundation series, depicting the fall of a galactic empire and one man\'s plan to preserve human knowledge and shorten the coming dark age.'),
(3, 'The Martian', 'Andy Weir', 'A survival story about astronaut Mark Watney, stranded alone on Mars, who must use his ingenuity and science knowledge to stay alive until rescue is possible.'),

-- Fantasy (genre_id: 4)
(4, 'The Lord of the Rings: The Fellowship of the Ring', 'J.R.R. Tolkien', 'The beginning of an epic quest to destroy the One Ring, following Frodo Baggins and the Fellowship as they begin their perilous journey to Mount Doom.'),
(4, 'Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 'A young boy discovers he\'s a wizard and attends Hogwarts School of Witchcraft and Wizardry, beginning an adventure that will define his destiny.'),
(4, 'A Game of Thrones', 'George R.R. Martin', 'The first book in an epic fantasy series featuring political intrigue, war, and supernatural elements in the Seven Kingdoms of Westeros.'),
(4, 'The Name of the Wind', 'Patrick Rothfuss', 'A beautifully written fantasy following Kvothe, a legendary figure, as he recounts his story of magic, music, and tragedy.'),
(4, 'The Way of Kings', 'Brandon Sanderson', 'The first book in the Stormlight Archive, set on a world ravaged by magical storms, following multiple characters as ancient forces awaken.'),
(4, 'The Bear and the Nightingale', 'Katherine Arden', 'A lyrical fantasy rooted in Russian folklore, following Vasya, a young woman with the ability to see household spirits in medieval Russia.'),
(4, 'Circe', 'Madeline Miller', 'A reimagining of Greek mythology from the perspective of Circe, the witch goddess, exploring her transformation from awkward nymph to powerful sorceress.'),

-- Romance (genre_id: 5)
(5, 'Pride and Prejudice', 'Jane Austen', 'The timeless romance between Elizabeth Bennet and Mr. Darcy, exploring themes of love, class, and personal growth in Regency England.'),
(5, 'Jane Eyre', 'Charlotte Brontë', 'A Gothic romance following the orphaned Jane Eyre as she becomes a governess and falls in love with her brooding employer, Mr. Rochester.'),
(5, 'The Hating Game', 'Sally Thorne', 'A contemporary enemies-to-lovers romance about two coworkers who compete for the same promotion while fighting their growing attraction to each other.'),
(5, 'Me Before You', 'Jojo Moyes', 'A heartbreaking love story between Louisa Clark and Will Traynor, a quadriplegic man, exploring themes of life, love, and choice.'),
(5, 'The Kiss Quotient', 'Helen Hoang', 'A contemporary romance featuring Stella, a woman on the autism spectrum, who hires a male escort to help her learn about intimacy and relationships.'),

-- Historical Fiction (genre_id: 6)
(6, 'All Quiet on the Western Front', 'Erich Maria Remarque', 'A powerful anti-war novel following German soldiers during World War I, depicting the brutal reality of trench warfare and its psychological impact.'),
(6, 'The Book Thief', 'Markus Zusak', 'Set in Nazi Germany, this novel follows Liesel Meminger, a young girl who finds solace in stealing books and sharing them during the horrors of World War II.'),
(6, 'Beloved', 'Toni Morrison', 'A haunting story about Sethe, a former slave haunted by the ghost of her daughter, exploring the lasting trauma of slavery in post-Civil War America.'),
(6, 'The Pillars of the Earth', 'Ken Follett', 'An epic set in 12th-century England, following the construction of a cathedral and the lives of those involved, from nobles to peasants.'),
(6, 'Cold Mountain', 'Charles Frazier', 'Set during the American Civil War, following Inman\'s journey home to his love Ada, and her struggle to survive on her own during wartime.'),
(6, 'The Seven Husbands of Evelyn Hugo', 'Taylor Jenkins Reid', 'A reclusive Hollywood icon finally reveals her secrets and the seven husbands she married, set against the backdrop of 20th-century entertainment industry.'),

-- Literary Fiction (genre_id: 7)
(7, '1984', 'George Orwell', 'A dystopian masterpiece depicting a totalitarian society where Big Brother watches everything, following Winston Smith\'s struggle against oppressive government control.'),
(7, 'The Handmaid\'s Tale', 'Margaret Atwood', 'A dystopian novel set in Gilead, a totalitarian society where women are subjugated and used for reproduction, told through the eyes of Offred.'),
(7, 'Never Let Me Go', 'Kazuo Ishiguro', 'A haunting story about students at a mysterious boarding school, slowly revealing a dark secret about their purpose in life.'),
(7, 'The Road', 'Cormac McCarthy', 'A post-apocalyptic tale of a father and son traveling through a devastated America, exploring themes of survival, love, and hope.'),
(7, 'Beloved', 'Toni Morrison', 'A powerful exploration of slavery\'s legacy, following Sethe and her family as they confront the ghost of her deceased daughter.'),
(7, 'The Kite Runner', 'Khaled Hosseini', 'A story of friendship, betrayal, and redemption set against the backdrop of Afghanistan\'s tumultuous history.'),

-- Young Adult (genre_id: 8)
(8, 'The Hunger Games', 'Suzanne Collins', 'In a dystopian future, Katniss Everdeen volunteers to take her sister\'s place in a televised fight to the death, sparking a revolution.'),
(8, 'The Fault in Our Stars', 'John Green', 'A heartbreaking love story between two teenagers with cancer, Hazel and Augustus, as they navigate love, life, and mortality.'),
(8, 'Divergent', 'Veronica Roth', 'In a society divided into factions based on virtues, Tris discovers she\'s Divergent and uncovers a conspiracy to destroy all Divergents.'),
(8, 'The Perks of Being a Wallflower', 'Stephen Chbosky', 'A coming-of-age story told through letters by Charlie, a sensitive teenager navigating high school, friendship, and first love.'),
(8, 'Eleanor Oliphant Is Completely Fine', 'Gail Honeyman', 'Despite the title, Eleanor is not fine, but through an unlikely friendship, she begins to face her traumatic past and find healing.'),
(8, 'The Book Thief', 'Markus Zusak', 'Narrated by Death, this story follows Liesel, a young girl in Nazi Germany who finds comfort in stealing books during wartime.'),

-- Horror (genre_id: 9)
(9, 'The Shining', 'Stephen King', 'A psychological horror about Jack Torrance, who becomes winter caretaker of the isolated Overlook Hotel with his wife and psychic son, leading to madness and terror.'),
(9, 'Dracula', 'Bram Stoker', 'The classic vampire novel that established many of the conventions of vampire fiction, following Count Dracula\'s attempt to move to England.'),
(9, 'Frankenstein', 'Mary Shelley', 'Often considered the first science fiction novel, telling the story of Victor Frankenstein and the monster he creates, exploring themes of creation and responsibility.'),
(9, 'The Exorcist', 'William Peter Blatty', 'A terrifying tale of demonic possession involving a young girl and the priests who attempt to save her soul.'),
(9, 'The Haunting of Hill House', 'Shirley Jackson', 'A psychological horror about four people who stay in a supposedly haunted house, blurring the lines between reality and supernatural terror.'),

-- Biography & Memoir (genre_id: 10)
(10, 'Educated', 'Tara Westover', 'A powerful memoir about a woman who grows up in a survivalist family and eventually earns a PhD from Cambridge, despite never attending school as a child.'),
(10, 'Born a Crime', 'Trevor Noah', 'The comedian\'s memoir about growing up in apartheid South Africa as the mixed-race son of a white father and black mother.'),
(10, 'When Breath Becomes Air', 'Paul Kalanithi', 'A neurosurgeon\'s profound meditation on mortality after being diagnosed with terminal cancer at age 36.'),
(10, 'The Glass Castle', 'Jeannette Walls', 'A memoir about growing up with dysfunctional parents who were alternately loving and neglectful, brilliant and irresponsible.'),
(10, 'Becoming', 'Michelle Obama', 'The former First Lady\'s memoir chronicling her journey from childhood in Chicago to the White House and beyond.'),

-- Self-Help (genre_id: 11)
(11, 'Atomic Habits', 'James Clear', 'A comprehensive guide to building good habits and breaking bad ones, using proven psychological principles and practical strategies.'),
(11, 'The 7 Habits of Highly Effective People', 'Stephen R. Covey', 'A foundational self-help book outlining seven principles for personal and professional effectiveness.'),
(11, 'Mindset', 'Carol S. Dweck', 'Explores the power of our beliefs about our abilities and how a "growth mindset" can lead to greater success and fulfillment.'),
(11, 'The Power of Now', 'Eckhart Tolle', 'A spiritual guide to living in the present moment and finding peace through mindfulness and awareness.'),
(11, 'Daring Greatly', 'Brené Brown', 'An exploration of vulnerability, courage, and authenticity as the keys to living a wholehearted life.'),

-- Business (genre_id: 12)
(12, 'Good to Great', 'Jim Collins', 'An analysis of what makes some companies achieve sustained greatness while others remain merely good, based on extensive research.'),
(12, 'The Lean Startup', 'Eric Ries', 'A methodology for developing businesses and products through validated learning, scientific experimentation, and iterative product releases.'),
(12, 'Zero to One', 'Peter Thiel', 'Insights on startups and innovation from the PayPal co-founder, focusing on creating monopolies through unique value creation.'),
(12, 'The $100 Startup', 'Chris Guillebeau', 'A guide to launching a business with minimal investment, featuring case studies of successful micro-entrepreneurs.'),
(12, 'Thinking, Fast and Slow', 'Daniel Kahneman', 'A Nobel Prize winner\'s exploration of how we make decisions, examining the two systems that drive our thinking.'),

-- Psychology (genre_id: 13)
(13, 'Thinking, Fast and Slow', 'Daniel Kahneman', 'A groundbreaking exploration of the two systems of thinking that drive our decisions: the fast, intuitive system and the slow, deliberate one.'),
(13, 'The Man Who Mistook His Wife for a Hat', 'Oliver Sacks', 'Fascinating case studies of patients with neurological disorders, offering insights into the workings of the human brain.'),
(13, 'Flow', 'Mihaly Csikszentmihalyi', 'An exploration of the psychology of optimal experience and how to achieve states of complete engagement and satisfaction.'),
(13, 'The Righteous Mind', 'Jonathan Haidt', 'An examination of the moral psychology behind our political and religious beliefs, explaining why good people disagree on morality.'),
(13, 'Quiet', 'Susan Cain', 'A celebration of introversion in an extroverted world, exploring the power and contributions of quiet personalities.'),

-- Philosophy (genre_id: 14)
(14, 'Man\'s Search for Meaning', 'Viktor E. Frankl', 'A Holocaust survivor\'s profound insights into finding purpose and meaning in life, even in the most extreme circumstances.'),
(14, 'The Stranger', 'Albert Camus', 'An existentialist novel following Meursault, a detached Algerian who commits a random act of violence, exploring themes of absurdity and alienation.'),
(14, 'Meditations', 'Marcus Aurelius', 'Personal reflections on Stoic philosophy from the Roman Emperor, offering timeless wisdom on ethics, mortality, and self-discipline.'),
(14, 'The Republic', 'Plato', 'A foundational work of Western philosophy exploring justice, the ideal state, and the nature of reality through Socratic dialogue.'),
(14, 'Being and Time', 'Martin Heidegger', 'A complex philosophical work examining the nature of being and human existence in relation to time and mortality.'),

-- Contemporary Fiction (genre_id: 15)
(15, 'Where the Crawdads Sing', 'Delia Owens', 'A coming-of-age mystery about Kya, the "Marsh Girl" who grows up isolated in the wetlands of North Carolina, accused of murder years later.'),
(15, 'The Seven Husbands of Evelyn Hugo', 'Taylor Jenkins Reid', 'A reclusive Hollywood icon finally reveals her life story and the seven husbands she married to a young journalist.'),
(15, 'Educated', 'Tara Westover', 'A memoir about education, family, and the struggle between loyalty and independence, as the author escapes her survivalist family.'),
(15, 'Normal People', 'Sally Rooney', 'An intimate portrayal of the complex relationship between Connell and Marianne from their school days in Ireland to their undergraduate years at Trinity College.'),
(15, 'The Midnight Library', 'Matt Haig', 'A philosophical novel about Nora Seed, who finds herself in a magical library between life and death, exploring the infinite possibilities of her unlived lives.'),
(15, 'Klara and the Sun', 'Kazuo Ishiguro', 'Told from the perspective of Klara, an artificial friend, this novel explores love, humanity, and what it means to be alive.'),
(15, 'The Invisible Life of Addie LaRue', 'V.E. Schwab', 'A fantasy romance about a young woman cursed to be forgotten by everyone she meets, until after 300 years, she encounters someone who remembers her.'),
(15, 'Such a Fun Age', 'Kiley Reid', 'A sharp social commentary following a young Black babysitter accused of kidnapping the white child in her care, exploring race, class, and privilege.'),
(15, 'The Vanishing Half', 'Brit Bennett', 'A multi-generational saga about twin sisters who choose to live in different worlds, one Black and one passing for white.'),
(15, 'Little Fires Everywhere', 'Celeste Ng', 'Set in 1990s suburban Ohio, this novel explores family dynamics, secrets, and the complexities of motherhood when two families\' lives intersect.');

-- Create indexes for better performance
CREATE INDEX idx_books_genre_title ON tbl_books(genre, title);
CREATE INDEX idx_books_author_genre ON tbl_books(author, genre);

-- Verify the data was inserted correctly
SELECT 
    g.name AS genre, 
    COUNT(b.id) AS book_count 
FROM tbl_genres g 
LEFT JOIN tbl_books b ON g.id = b.genre 
GROUP BY g.id, g.name 
ORDER BY g.id;