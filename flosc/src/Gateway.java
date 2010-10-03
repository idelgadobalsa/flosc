/*import java.awt.event.*;import java.util.*;import java.awt.*;import java.io.*;import java.net.*;*/import javax.swing.JFrame;import javax.swing.JLabel;import javax.swing.JTextField;import java.awt.FlowLayout;import java.awt.Button;import java.awt.Menu;import java.awt.MenuBar;import java.awt.AWTException;import java.awt.SystemTray;import java.awt.Image;import java.awt.Toolkit;import java.awt.PopupMenu;import java.awt.MenuItem;import java.awt.TrayIcon;import java.awt.event.ActionEvent;import java.awt.event.ActionListener;import java.net.URL;/** * Gateway <BR><BR> OpenSoundControl / Flash Gateway Server. Usage: java Gateway [oscPort] [flashPort] * @author    Ben Chun          ben@benchun.net * @author	  Ignacio Delgado   idelgado@h-umus.it * @version   2.0 */public class Gateway extends JFrame implements ActionListener{    /**	 * 	 */	private static final long serialVersionUID = 1L;	private OscServer oscServer;    private TcpServer tcpServer;        private static Gateway myGateway;        private int _oscPort;    private int _flashPort;        private JTextField flashportInput;    private JTextField oscPortInput;    private Button startButton;    private MenuItem startItem;    /**     * Constructor for the Gateway.     * @param   flashPort   TCP port for Flash client connections.     * @param   oscPort     UDP port for OSC communication.    */    public Gateway(int oscPort, int flashPort)     {        _oscPort = oscPort;        _flashPort = flashPort;                /*System.out.println("Attempting to start OSC / Flash Gateway server");		// --- create the servers		oscServer = new OscServer(oscPort, this);		tcpServer = new TcpServer(flashPort, this);		// --- start their threads		oscServer.start();		tcpServer.start();*/    }        public void startServers()    {    	System.out.println("Attempting to start OSC / Flash Gateway server");		// --- create the servers		oscServer = new OscServer(_oscPort, this);		tcpServer = new TcpServer(_flashPort, this);		// --- start their threads		oscServer.start();		tcpServer.start();    }        public void stopServers()    {    	oscServer.killServer();    	tcpServer.killServer();    }    /**     * Broadcasts a message too all connected TCP clients.     *     * @param   message    The message to broadcast.    */    public void broadcastMessage(String message)     {    	tcpServer.broadcastMessage(message);    }    /**     * Sends a packet to an OSC client via UDP.     *     * @param packet   The packet to send.     */    public void sendPacket(OscPacket packet)     {		Debug.writeActivity("Gateway transporting OSC packet.");		oscServer.sendPacket(packet);    }    /**     * Create the GUI and show it.  For thread safety,     * this method should be invoked from the     * event-dispatching thread.     */    private static void createAndShowGUI()     { /*       //Create and set up the window.        JFrame frame = new JFrame("Flosc 1.0");        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);        //Add the ubiquitous "Hello World" label.        JLabel label = new JLabel("Gateway Started");        frame.getContentPane().add(label);        //Display the window.        frame.pack();        frame.setVisible(true);  */        	myGateway.setSize(200,200);    	myGateway.setTitle("Flosc 2.0");    	myGateway.setLayout(new FlowLayout(FlowLayout.LEFT));    	myGateway.setResizable(false);    	    	MenuBar menubar = new MenuBar();    	Menu menu = new Menu("File");    	MenuItem quitItem = new MenuItem("quit");    	quitItem.addActionListener(myGateway);    	menu.add(quitItem);    	menubar.add(menu);     	myGateway.setMenuBar(menubar);    	    	JLabel label = new JLabel("Gateway config                   ");    	myGateway.getContentPane().add(label);    	//myGateway.pack();    	    	    	JLabel flashportLabel = new JLabel("Flash port:");    	myGateway.getContentPane().add(flashportLabel);    	    	myGateway.flashportInput = new JTextField(10);    	myGateway.flashportInput.setText(((Integer)myGateway._flashPort).toString());    	//myGateway.flashportInput.setEditable(false);    	myGateway.getContentPane().add(myGateway.flashportInput);    	    	JLabel oscPortLabel = new JLabel("OSC port: ");    	myGateway.getContentPane().add(oscPortLabel);    	    	myGateway.oscPortInput = new JTextField(10);    	myGateway.oscPortInput.setText(((Integer)myGateway._oscPort).toString());    	//myGateway.oscPortInput.setEditable(false);    	myGateway.getContentPane().add(myGateway.oscPortInput);    	    	myGateway.startButton = new Button("Start");    	myGateway.startButton.addActionListener(myGateway);    	myGateway.getContentPane().add(myGateway.startButton);    	    	myGateway.setVisible(true);    	    	    	        if(SystemTray.isSupported())        {        	SystemTray systemTray = SystemTray.getSystemTray();        	URL url = myGateway.getClass().getResource("tray.png");        	Image image = Toolkit.getDefaultToolkit().getImage(url);        	PopupMenu popupMenu = new PopupMenu();        	        	myGateway.startItem = new MenuItem("Start Flosc Server");        	myGateway.startItem.setActionCommand("Start");        	myGateway.startItem.addActionListener(myGateway);        	popupMenu.add(myGateway.startItem);        	        	MenuItem quitItem2 = new MenuItem("Quit");        	quitItem2.addActionListener(myGateway);        	popupMenu.add(quitItem2);        	        	TrayIcon trayIcon = new TrayIcon(image,"Flosc",popupMenu);        	trayIcon.addActionListener(myGateway);        	        	try {				systemTray.add(trayIcon);			} catch (AWTException e) {				// TODO Auto-generated catch block				e.printStackTrace();			}	        }    }            public static void main(String args[])     {        // --- if correct number of arguments    	    	       /* if(args.length == 2)         {        	myGateway = new Gateway( Integer.parseInt(args[0]),					     Integer.parseInt(args[1]) );        }         else         {*/        // otherwise give correct usage            //System.out.println("Usage: java Gateway [oscPort] [flashPort]");        	myGateway = new Gateway(3334,3000);        /*}*/                /*myGateway.setSize(100, 100);        myGateway.setTitle("Flosc");        myGateway.setVisible(true);*/                javax.swing.SwingUtilities.invokeLater(new Runnable()         {            public void run() {                createAndShowGUI();            }        });    }	public void actionPerformed(ActionEvent arg0) {		String str = arg0.getActionCommand();		if(str==null)		{			if(myGateway.isVisible())			{				myGateway.setVisible(false);			}			else			{				myGateway.setVisible(true);			}		}		else if(str.equals("Start")){			myGateway.startButton.setLabel("Stop");			myGateway.startButton.setActionCommand("Stop");			myGateway.startItem.setLabel("Stop Flosc Server");			myGateway.startItem.setActionCommand("Stop");						myGateway.oscPortInput.setEditable(false);			myGateway.flashportInput.setEditable(false);						Integer iFlashPort = new Integer(myGateway.flashportInput.getText());			myGateway._flashPort = iFlashPort.intValue();						Integer iOSCPort = new Integer(myGateway.oscPortInput.getText());			myGateway._oscPort= iOSCPort.intValue();						startServers();			//myGateway.setVisible(false);		}		else if(str.equals("Stop")){			myGateway.startButton.setLabel("Start");			myGateway.startButton.setActionCommand("Start");			myGateway.startItem.setLabel("Start Flosc Server");			myGateway.startItem.setActionCommand("Start");			stopServers();						myGateway.oscPortInput.setEditable(true);			myGateway.flashportInput.setEditable(true);						//myGateway.setVisible(false);		}		else if(str.equals("quit"))		{			System.exit(0);		}			}}